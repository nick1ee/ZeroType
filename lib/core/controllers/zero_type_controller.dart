import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zero_type/core/constants/model_pricing.dart';
import 'package:zero_type/core/constants/app_constants.dart';
import 'package:zero_type/core/di/injection.dart';
import 'package:zero_type/core/services/app_logger.dart';
import 'package:zero_type/core/services/recording_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zero_type/core/services/sound_service.dart';
import 'package:zero_type/core/services/speech_recognition_service.dart';
import 'package:zero_type/core/state/zero_type_state.dart';
import 'package:zero_type/features/history/domain/entities/transcription_record.dart';
import 'package:zero_type/features/history/domain/repositories/history_repository.dart';
import 'package:zero_type/features/model_config/presentation/controllers/model_config_controller.dart';
import 'package:zero_type/features/prompt/presentation/controllers/prompt_controller.dart';
import 'package:zero_type/features/dictionary/presentation/controllers/dictionary_controller.dart';
import 'package:zero_type/features/settings/presentation/controllers/settings_controller.dart';

part 'zero_type_controller.g.dart';

@Riverpod(keepAlive: true)
class ZeroTypeController extends _$ZeroTypeController {
  late final RecordingService _recordingService;
  bool _cancelled = false;
  DateTime? _recordingStartTime;
  Timer? _maxDurationTimer;

  @override
  ZeroTypeState build() {
    _recordingService = RecordingService();
    ref.onDispose(() => _recordingService.dispose());

    // Listen for cancel signals from the native overlay (X button or ESC)
    const controlChannel = MethodChannel('com.zerotype.app/control');
    controlChannel.setMethodCallHandler((call) async {
      if (call.method == 'cancel') await cancel();
    });

    return const ZeroTypeState();
  }

  Future<void> toggleRecording() async {
    AppLogger.log('ZeroType',
        'hotkey activated; current status=${state.status.name}');
    if (state.status == ZeroTypeStatus.recording) {
      await _stopAndProcess();
    } else if (state.status == ZeroTypeStatus.idle) {
      await _startRecording();
    } else if (state.status == ZeroTypeStatus.cancelling) {
      return;
    } else {
      await cancel();
    }
  }

  Future<void> cancel() async {
    _maxDurationTimer?.cancel();
    _maxDurationTimer = null;
    _cancelled = true;
    if (state.status == ZeroTypeStatus.recording) {
      state = state.copyWith(status: ZeroTypeStatus.cancelling);
      unawaited(_showNativeOverlay('cancelling', '取消中'));
      await _recordingService.cancelRecording();
    }
    await getIt<SoundService>().playCancelSound();
    await getIt<SoundService>().resumeMusic();
    state = const ZeroTypeState();
    await _hideNativeOverlay();
  }

  Future<void> _startRecording() async {
    _cancelled = false;

    final config = await ref.read(speechProviderControllerProvider.future);
    if (config.providerId == null || config.providerId!.isEmpty ||
        config.apiKey == null || config.apiKey!.isEmpty ||
        config.modelId == null || config.modelId!.isEmpty) {
      await _failStartup('請先完成語音辨識模型設定（provider/model/apiKey 至少一項缺失）');
      return;
    }

    // [優化1] 同時檢查 accessibility 與麥克風權限
    const permissionChannel = MethodChannel('com.zerotype.app/permission');
    bool isAccessibilityOk = false;
    bool hasPermission = false;
    try {
      final results = await Future.wait([
        permissionChannel
            .invokeMethod<bool>('checkAccessibility')
            .then((v) => v ?? false)
            .catchError((_) => false),
        _recordingService.requestPermission().catchError((_) => false),
      ]);
      isAccessibilityOk = results[0] as bool;
      hasPermission = results[1] as bool;
    } catch (_) {}

    if (!ref.mounted || _cancelled) return;
    if (!isAccessibilityOk) {
      await _failStartup('請先授權輔助使用權限');
      return;
    }
    if (!hasPermission) {
      await _failStartup('請先授權麥克風權限');
      return;
    }

    // [優化2] 音效不阻塞錄音啟動
    unawaited(getIt<SoundService>().pauseMusic());
    unawaited(getIt<SoundService>().playStartSound());

    if (!ref.mounted || _cancelled) return;
    state = state.copyWith(status: ZeroTypeStatus.recording, amplitude: 0.0);
    _recordingStartTime = DateTime.now();

    // Start max-duration safety timer from user setting (default 1 min, max 5 min)
    final maxMinutes = getIt<SharedPreferences>()
        .getInt(AppConstants.maxRecordingMinutesKey) ?? 1;
    _maxDurationTimer = Timer(Duration(minutes: maxMinutes), () {
      if (state.status == ZeroTypeStatus.recording) {
        print('[ZeroType] Max recording duration reached, auto-stopping.');
        _stopAndProcess();
      }
    });

    // [優化3] overlay 顯示與錄音初始化同步進行
    try {
      await Future.wait([
        _showNativeOverlay('recording', '錄音中'),
        _recordingService.startRecording(
          onAmplitude: (amp) {
            if (ref.mounted && !_cancelled) {
              state = state.copyWith(amplitude: amp);
              _updateNativeAmplitude(amp);
            }
          },
        ),
      ]);
    } catch (e, st) {
      AppLogger.log('ZeroType', 'startRecording threw', error: e, st: st);
      if (!ref.mounted || _cancelled) return;
      state = state.copyWith(
        status: ZeroTypeStatus.error,
        errorMessage: '錄音啟動失敗：$e',
      );
      await _showNativeOverlay('error', '錄音啟動失敗：$e');
      await Future.delayed(const Duration(seconds: 3));
      if (ref.mounted && !_cancelled) {
        state = const ZeroTypeState();
        await _hideNativeOverlay();
      }
    }
  }

  /// Optional post-transcription LLM refinement. Returns the refined text on
  /// success, `null` if the feature is disabled / not configured / errors
  /// (the caller falls back to the raw transcript so a misconfigured
  /// refinement step never blocks the user from getting their text pasted).
  Future<String?> _maybeRefine(String rawText) async {
    final settings = await ref.read(settingsControllerProvider.future);
    if (!settings.refinementEnabled) {
      AppLogger.log('Refine', 'skipped: toggle is off');
      return null;
    }
    final cfg = await ref.read(refinementProviderControllerProvider.future);
    if (cfg.providerId == null || cfg.providerId!.isEmpty ||
        cfg.modelId == null || cfg.modelId!.isEmpty ||
        cfg.apiKey == null || cfg.apiKey!.isEmpty) {
      AppLogger.log('Refine',
          'skipped: refinement provider/model/apiKey not all configured');
      return null;
    }
    try {
      await _showNativeOverlay('transcribing', '優化中');
      final prompt = await ref.read(refinementPromptControllerProvider.future);
      final refined = await getIt<SpeechRecognitionService>().refine(
        rawText: rawText,
        apiKey: cfg.apiKey!,
        provider: cfg.providerId!,
        model: cfg.modelId!,
        prompt: prompt,
        customEndpoint: cfg.customEndpoint,
      );
      if (refined.text.isEmpty) {
        AppLogger.log('Refine', 'returned empty; falling back to raw');
        return null;
      }
      AppLogger.log('Refine',
          'success rawLen=${rawText.length} refinedLen=${refined.text.length}');
      return refined.text;
    } catch (e, st) {
      AppLogger.log('Refine', 'failed; falling back to raw',
          error: e, st: st);
      return null;
    }
  }

  /// Centralised early-exit error path. Sets state to error with [msg] (so the
  /// Flutter overlay on Windows shows the actual reason), fires the macOS
  /// native overlay equivalent, plays cancel sound, and resets after 3s.
  Future<void> _failStartup(String msg) async {
    AppLogger.log('ZeroType', 'startRecording aborted: $msg');
    state = state.copyWith(
      status: ZeroTypeStatus.error,
      errorMessage: msg,
    );
    await _showNativeOverlay('error', msg);
    await getIt<SoundService>().playCancelSound();
    await Future.delayed(const Duration(seconds: 3));
    if (ref.mounted && !_cancelled) {
      state = const ZeroTypeState();
      await _hideNativeOverlay();
    }
  }

  Future<TranscriptionResult?> _transcribe(String filePath) async {
    final config = await ref.read(speechProviderControllerProvider.future);
    final prompt = await ref.read(speechPromptControllerProvider.future);
    final dictionaryPrompt =
        await ref.read(dictionaryRepositoryProvider).buildDictionaryPrompt();

    if (config.providerId == null ||
        config.apiKey == null ||
        config.modelId == null) {
      throw Exception('請先完成語音辨識模型設定');
    }

    final finalPrompt =
        dictionaryPrompt.isEmpty ? prompt : '$prompt\n\n$dictionaryPrompt';

    final service = getIt<SpeechRecognitionService>();
    return service.transcribe(
      audioFilePath: filePath,
      apiKey: config.apiKey!,
      provider: config.providerId!,
      model: config.modelId!,
      prompt: finalPrompt,
      customEndpoint: config.customEndpoint,
    );
  }

  Future<void> _stopAndProcess() async {
    _maxDurationTimer?.cancel();
    _maxDurationTimer = null;
    state = state.copyWith(status: ZeroTypeStatus.saving);
    await _showNativeOverlay('saving', '擷取中');

    final stopTime = DateTime.now();
    final durationMs = _recordingStartTime != null
        ? stopTime.difference(_recordingStartTime!).inMilliseconds
        : null;

    try {
      final stopFuture = _recordingService.stopRecording();
      final soundFuture = getIt<SoundService>().playStopSound();
      getIt<SoundService>().resumeMusic();

      final filePath = await stopFuture;
      await soundFuture;

      if (!ref.mounted || _cancelled || filePath == null) {
        state = const ZeroTypeState();
        await _hideNativeOverlay();
        return;
      }

      state = state.copyWith(status: ZeroTypeStatus.transcribing);
      await _showNativeOverlay('transcribing', '辨識中');

      final config = await ref.read(speechProviderControllerProvider.future);
      final result = await _transcribe(filePath);

      if (result == null || result.text.isEmpty) {
        // Cleanup temp file on empty result
        await _recordingService.deleteFile(filePath);
        throw Exception('未能辨識出任何文字');
      }

      // Optional refinement step: feed the transcript through a chat LLM
      // to clean up filler words / fix punctuation. Settings toggle is
      // checked first; if off, this is a no-op.
      final refinedText = await _maybeRefine(result.text);
      final finalText = refinedText ?? result.text;

      // Move audio to history dir and save record
      final historyRepo = getIt<HistoryRepository>();
      final audioHistoryPath = await historyRepo.moveAudioFile(filePath);

      final recordId = DateTime.now().millisecondsSinceEpoch.toString();
      final record = TranscriptionRecord(
        id: recordId,
        text: finalText,
        createdAt: DateTime.now(),
        audioPath: audioHistoryPath,
        durationMs: durationMs,
        provider: config.providerId ?? '',
        model: config.modelId ?? '',
        inputTokens: result.inputTokens,
        outputTokens: result.outputTokens,
        costUsd: calculateCost(
          config.modelId ?? '',
          result.inputTokens,
          result.outputTokens,
        ),
      );
      await historyRepo.addRecord(record);
      await historyRepo.accumulateStats(record);

      // Output
      state = state.copyWith(status: ZeroTypeStatus.done, result: finalText);
      await Clipboard.setData(ClipboardData(text: finalText));
      await Future.delayed(const Duration(milliseconds: 150));

      print('[ZeroType] Simulating paste...');
      const channel = MethodChannel('com.zerotype.app/keyboard');
      await channel.invokeMethod('simulatePaste');

      await _showNativeOverlay('done', '已完成');
      await Future.delayed(const Duration(seconds: 2));

      if (ref.mounted && !_cancelled) {
        state = const ZeroTypeState();
        await _hideNativeOverlay();
      }
    } catch (e, st) {
      AppLogger.log('ZeroType', '_stopAndProcess threw',
          error: e, st: st);
      if (!ref.mounted || _cancelled) return;
      state = state.copyWith(
        status: ZeroTypeStatus.error,
        errorMessage: e.toString(),
      );
      await _showNativeOverlay('error', '處理失敗：$e');
      await getIt<SoundService>().resumeMusic();
      await Future.delayed(const Duration(seconds: 3));
      if (ref.mounted && !_cancelled) {
        state = const ZeroTypeState();
        await _hideNativeOverlay();
      }
    }
  }

  Future<void> showOverlay(String status, String message) =>
      _showNativeOverlay(status, message);

  Future<void> hideOverlay() => _hideNativeOverlay();

  Future<void> _showNativeOverlay(String status, String message) async {
    const channel = MethodChannel('com.zerotype.app/overlay');
    try {
      await channel.invokeMethod<void>('show', {
        'status': status,
        'message': message,
      });
    } catch (_) {}
  }

  Future<void> _hideNativeOverlay() async {
    const channel = MethodChannel('com.zerotype.app/overlay');
    try {
      await channel.invokeMethod<void>('hide');
    } catch (_) {}
  }

  Future<void> _updateNativeAmplitude(double amplitude) async {
    const channel = MethodChannel('com.zerotype.app/overlay');
    try {
      await channel.invokeMethod<void>('updateAmplitude', {
        'amplitude': amplitude,
      });
    } catch (_) {}
  }
}
