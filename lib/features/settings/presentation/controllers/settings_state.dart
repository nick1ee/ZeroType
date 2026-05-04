import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:zero_type/core/services/sound_service.dart';

part 'settings_state.freezed.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(false) bool launchAtStartup,
    required HotKey hotkey,
    @Default(false) bool isAccessibilityAuthorized,
    @Default(false) bool isMicrophoneAuthorized,
    @Default(false) bool isRecordingHotkey,
    @Default(true) bool soundEnabled,
    @Default(kDefaultStartSound) String startSound,
    @Default(kDefaultStopSound) String stopSound,
    @Default(7) int historyRetentionDays,
    @Default(1) int maxRecordingMinutes,
    @Default(false) bool refinementEnabled,
  }) = _SettingsState;
}
