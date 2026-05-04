import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zero_type/core/constants/app_constants.dart';
import 'package:zero_type/core/di/injection.dart';
import 'package:zero_type/core/services/hotkey_service.dart';
import 'package:zero_type/core/services/sound_service.dart';
import 'settings_state.dart';

part 'settings_controller.g.dart';

@riverpod
class SettingsController extends _$SettingsController {
  @override
  Future<SettingsState> build() async {
    print('[SettingsController] Building state...');

    try {
      print('[SettingsController] Checking if launch at startup is enabled...');
      final isLaunchEnabled = getIt<SharedPreferences>().getBool(AppConstants.launchAtStartupKey) ?? false;
      
      print('[SettingsController] Fetching current hotkey...');
      final hotkey = getIt<HotkeyService>().currentHotkey;

      print('[SettingsController] Fetching permissions...');
      final isAccessibilityAuthorized = await _checkAccessibility();
      final isMicrophoneAuthorized = await AudioRecorder().hasPermission();

      final prefs = getIt<SharedPreferences>();
      final soundEnabled = prefs.getBool(AppConstants.soundEnabledKey) ?? true;
      final startSound = prefs.getString(AppConstants.startSoundKey) ?? kDefaultStartSound;
      final stopSound = prefs.getString(AppConstants.stopSoundKey) ?? kDefaultStopSound;
      final historyRetentionDays = prefs.getInt(AppConstants.historyRetentionDaysKey) ?? 7;
      final maxRecordingMinutes = prefs.getInt(AppConstants.maxRecordingMinutesKey) ?? 1;
      final refinementEnabled =
          prefs.getBool(AppConstants.isRefinementEnabledKey) ?? false;

      print('[SettingsController] Build complete.');
      return SettingsState(
        launchAtStartup: isLaunchEnabled,
        hotkey: hotkey,
        isAccessibilityAuthorized: isAccessibilityAuthorized,
        isMicrophoneAuthorized: isMicrophoneAuthorized,
        soundEnabled: soundEnabled,
        startSound: startSound,
        stopSound: stopSound,
        historyRetentionDays: historyRetentionDays,
        maxRecordingMinutes: maxRecordingMinutes,
        refinementEnabled: refinementEnabled,
      );
    } catch (e, st) {
      print('[SettingsController] Error building settings state: $e\n$st');
      rethrow;
    }
  }

  Future<void> toggleLaunchAtStartup(bool value) async {
    print('[SettingsController] Toggling launchAtStartup to $value...');
    try {
      if (value) {
        await LaunchAtStartup.instance.enable();
      } else {
        await LaunchAtStartup.instance.disable();
      }
    } on MissingPluginException {
      print('[SettingsController] toggleLaunchAtStartup failed: plugin missing.');
      return;
    } catch (e) {
      print('[SettingsController] toggleLaunchAtStartup error: $e');
      return;
    }
    await getIt<SharedPreferences>().setBool(AppConstants.launchAtStartupKey, value);
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncData(currentState.copyWith(launchAtStartup: value));
    }
  }

  Future<void> startRecordingHotkey() async {
    print('[SettingsController] Starting hotkey recording...');
    final currentState = state.value;
    if (currentState == null) return;

    // Disable global hotkey BEFORE showing overlay to prevent accidental triggers
    await getIt<HotkeyService>().pause();

    state = AsyncData(currentState.copyWith(isRecordingHotkey: true));
  }

  void stopRecordingHotkey() {
    print('[SettingsController] Stopping hotkey recording...');
    final currentState = state.value;
    if (currentState == null) return;
    
    // Re-enable global hotkey
    getIt<HotkeyService>().resume();
    
    state = AsyncData(currentState.copyWith(isRecordingHotkey: false));
  }

  Future<void> saveHotkey(List<PhysicalKeyboardKey> keys) async {
    print('[SettingsController] Saving hotkey with keys: $keys');
    
    final List<HotKeyModifier> modifiers = [];
    PhysicalKeyboardKey? mainKey;

    for (final key in keys) {
      if (key == PhysicalKeyboardKey.metaLeft || key == PhysicalKeyboardKey.metaRight) {
        if (!modifiers.contains(HotKeyModifier.meta)) modifiers.add(HotKeyModifier.meta);
      } else if (key == PhysicalKeyboardKey.controlLeft || key == PhysicalKeyboardKey.controlRight) {
        if (!modifiers.contains(HotKeyModifier.control)) modifiers.add(HotKeyModifier.control);
      } else if (key == PhysicalKeyboardKey.altLeft || key == PhysicalKeyboardKey.altRight) {
        if (!modifiers.contains(HotKeyModifier.alt)) modifiers.add(HotKeyModifier.alt);
      } else if (key == PhysicalKeyboardKey.shiftLeft || key == PhysicalKeyboardKey.shiftRight) {
        if (!modifiers.contains(HotKeyModifier.shift)) modifiers.add(HotKeyModifier.shift);
      } else {
        // Take the last non-modifier key as the main key
        mainKey = key;
      }
    }

    if (mainKey == null) {
      print('[SettingsController] No main key selected, ignoring save.');
      stopRecordingHotkey();
      return;
    }

    final newHotKey = HotKey(
      key: mainKey,
      modifiers: modifiers,
      scope: HotKeyScope.system,
    );

    await getIt<HotkeyService>().updateHotkey(newHotKey);
    
    // Stop recording and trigger refresh
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncData(currentState.copyWith(
        isRecordingHotkey: false,
        hotkey: newHotKey,
      ));
    }
    
    // Resume local hotkey (already handled in stopRecordingHotkey but stay safe)
    getIt<HotkeyService>().resume();
  }

  Future<void> toggleSound(bool value) async {
    await getIt<SharedPreferences>().setBool(AppConstants.soundEnabledKey, value);
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncData(currentState.copyWith(soundEnabled: value));
    }
  }

  Future<void> setStartSound(String path) async {
    await getIt<SharedPreferences>().setString(AppConstants.startSoundKey, path);
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncData(currentState.copyWith(startSound: path));
    }
  }

  Future<void> setStopSound(String path) async {
    await getIt<SharedPreferences>().setString(AppConstants.stopSoundKey, path);
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncData(currentState.copyWith(stopSound: path));
    }
  }

  Future<void> setHistoryRetentionDays(int days) async {
    await getIt<SharedPreferences>().setInt(AppConstants.historyRetentionDaysKey, days);
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncData(currentState.copyWith(historyRetentionDays: days));
    }
  }

  Future<void> setMaxRecordingMinutes(int minutes) async {
    await getIt<SharedPreferences>().setInt(AppConstants.maxRecordingMinutesKey, minutes);
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncData(currentState.copyWith(maxRecordingMinutes: minutes));
    }
  }

  Future<void> toggleRefinementEnabled(bool value) async {
    await getIt<SharedPreferences>()
        .setBool(AppConstants.isRefinementEnabledKey, value);
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncData(currentState.copyWith(refinementEnabled: value));
    }
  }

  /// Called by SettingsPage whenever it becomes visible.
  Future<void> refreshPermissions() async {
    // Run checks independently of current state loading status
    final isAccessibility = await _checkAccessibility();
    final isMicrophone = await AudioRecorder().hasPermission();

    final currentState = state.value;
    if (currentState != null) {
      state = AsyncData(currentState.copyWith(
        isAccessibilityAuthorized: isAccessibility,
        isMicrophoneAuthorized: isMicrophone,
      ));
    } else {
      // State is still loading (initial build not done yet);
      // wait for it to complete, then update
      state.whenData((s) {
        state = AsyncData(s.copyWith(
          isAccessibilityAuthorized: isAccessibility,
          isMicrophoneAuthorized: isMicrophone,
        ));
      });
    }
  }

  Future<bool> _checkAccessibility() async {
    // Windows doesn't require Accessibility permission for SendInput
    if (Platform.isWindows) return true;
    const channel = MethodChannel('com.zerotype.app/permission');
    try {
      return await channel.invokeMethod<bool>('checkAccessibility') ?? false;
    } catch (e) {
      print('[SettingsController] checkAccessibility error: $e');
      return false;
    }
  }
}
