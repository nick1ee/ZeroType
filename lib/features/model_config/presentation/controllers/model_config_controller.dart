import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zero_type/core/di/injection.dart';
import 'package:zero_type/core/services/speech_recognition_service.dart';
import 'package:zero_type/features/model_config/data/repositories/model_config_repository_impl.dart';
import 'package:zero_type/features/model_config/domain/entities/ai_provider.dart';
import 'package:zero_type/features/model_config/domain/repositories/model_config_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'model_config_controller.g.dart';

ModelConfigRepository _buildRepository() => ModelConfigRepositoryImpl(
      prefs: getIt<SharedPreferences>(),
    );

@riverpod
Future<ProvidersConfig> providersConfig(Ref ref) async {
  final repo = _buildRepository();
  return repo.loadProvidersConfig();
}

@riverpod
class SpeechProviderController extends _$SpeechProviderController {
  ModelConfigRepository get _repo => _buildRepository();

  @override
  Future<({String? providerId, String? modelId, String? apiKey, String? customEndpoint})>
      build() async {
    var providerId = await _repo.getSelectedSpeechProviderId();

    // Auto-select the first provider on first launch so saveApiKey/selectModel work correctly
    if (providerId == null) {
      final config = await _repo.loadProvidersConfig();
      if (config.speechRecognition.isNotEmpty) {
        providerId = config.speechRecognition.first.id;
        await _repo.saveSelectedSpeechProviderId(providerId);
      }
    }

    return (
      providerId: providerId,
      modelId: await _repo.getSelectedSpeechModelId(providerId ?? ''),
      apiKey: await _repo.getSpeechApiKey(providerId ?? ''),
      customEndpoint: await _repo.getCustomEndpoint(providerId ?? ''),
    );
  }

  Future<void> selectProvider(String providerId) async {
    await _repo.saveSelectedSpeechProviderId(providerId);
    ref.invalidateSelf();
  }

  Future<void> selectModel(String modelId) async {
    final state = await future;
    if (state.providerId != null) {
      await _repo.saveSelectedSpeechModelId(state.providerId!, modelId);
      ref.invalidateSelf();
    }
  }

  Future<void> saveApiKey(String apiKey) async {
    final state = await future;
    if (state.providerId != null) {
      await _repo.saveSpeechApiKey(state.providerId!, apiKey);
      ref.invalidateSelf();
    }
  }

  Future<void> saveCustomEndpoint(String endpoint) async {
    final state = await future;
    if (state.providerId != null) {
      await _repo.saveCustomEndpoint(state.providerId!, endpoint);
      ref.invalidateSelf();
    }
  }
}

/// Holds the dynamically-fetched model list for an OpenAI-compatible provider
/// (currently used by `litellm`). Returns the cached list immediately on
/// build; call `refresh()` to hit `/v1/models` and update the cache.
@Riverpod(keepAlive: true)
class DynamicModelsController extends _$DynamicModelsController {
  ModelConfigRepository get _repo => _buildRepository();
  SpeechRecognitionService get _service => getIt<SpeechRecognitionService>();

  @override
  Future<List<AiModel>> build(String providerId) async {
    return _repo.getCachedModels(providerId);
  }

  Future<void> refresh({
    required String providerId,
    required String baseUrl,
    required String apiKey,
  }) async {
    state = const AsyncLoading();
    try {
      final fetched = await _service.fetchAvailableModels(
        baseUrl: baseUrl,
        apiKey: apiKey,
      );
      final models =
          fetched.map((m) => AiModel(id: m.id, name: m.name)).toList();
      await _repo.saveCachedModels(providerId, models);
      state = AsyncData(models);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

@riverpod
class RefinementProviderController extends _$RefinementProviderController {
  ModelConfigRepository get _repo => _buildRepository();

  @override
  Future<({String? providerId, String? modelId, String? apiKey, String? customEndpoint})>
      build() async {
    final providerId = await _repo.getSelectedRefinementProviderId();
    return (
      providerId: providerId,
      modelId: providerId == null
          ? null
          : await _repo.getSelectedRefinementModelId(providerId),
      apiKey: providerId == null
          ? null
          : await _repo.getRefinementApiKey(providerId),
      customEndpoint: providerId == null
          ? null
          : await _repo.getRefinementCustomEndpoint(providerId),
    );
  }

  Future<void> selectProvider(String providerId) async {
    await _repo.saveSelectedRefinementProviderId(providerId);
    ref.invalidateSelf();
  }

  Future<void> selectModel(String modelId) async {
    final s = await future;
    if (s.providerId != null) {
      await _repo.saveSelectedRefinementModelId(s.providerId!, modelId);
      ref.invalidateSelf();
    }
  }

  Future<void> saveApiKey(String apiKey) async {
    final s = await future;
    if (s.providerId != null) {
      await _repo.saveRefinementApiKey(s.providerId!, apiKey);
      ref.invalidateSelf();
    }
  }

  Future<void> saveCustomEndpoint(String endpoint) async {
    final s = await future;
    if (s.providerId != null) {
      await _repo.saveRefinementCustomEndpoint(s.providerId!, endpoint);
      ref.invalidateSelf();
    }
  }
}

/// Refinement-specific dynamic model list (separate cache from speech, so the
/// user can point speech and refinement at different LiteLLM proxies if they
/// want).
@Riverpod(keepAlive: true)
class DynamicRefinementModelsController
    extends _$DynamicRefinementModelsController {
  ModelConfigRepository get _repo => _buildRepository();
  SpeechRecognitionService get _service => getIt<SpeechRecognitionService>();

  @override
  Future<List<AiModel>> build(String providerId) async {
    return _repo.getRefinementCachedModels(providerId);
  }

  Future<void> refresh({
    required String providerId,
    required String baseUrl,
    required String apiKey,
  }) async {
    state = const AsyncLoading();
    try {
      final fetched = await _service.fetchAvailableModels(
        baseUrl: baseUrl,
        apiKey: apiKey,
      );
      final models =
          fetched.map((m) => AiModel(id: m.id, name: m.name)).toList();
      await _repo.saveRefinementCachedModels(providerId, models);
      state = AsyncData(models);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

