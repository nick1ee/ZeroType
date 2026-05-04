import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:zero_type/core/di/injection.dart';
import 'package:zero_type/core/services/sound_service.dart';
import 'package:zero_type/core/theme/theme_controller.dart';
import '../controllers/settings_controller.dart';

String _modifierLabel(HotKeyModifier mod) {
  if (Platform.isWindows) {
    switch (mod) {
      case HotKeyModifier.meta:
        return 'Win';
      case HotKeyModifier.control:
        return 'Ctrl';
      case HotKeyModifier.alt:
        return 'Alt';
      case HotKeyModifier.shift:
        return 'Shift';
      default:
        return '';
    }
  }
  switch (mod) {
    case HotKeyModifier.meta:
      return '⌘ Command';
    case HotKeyModifier.control:
      return '⌃ Control';
    case HotKeyModifier.alt:
      return '⌥ Option';
    case HotKeyModifier.shift:
      return '⇧ Shift';
    default:
      return '';
  }
}

@RoutePage()
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> with WidgetsBindingObserver, AutoRouteAwareStateMixin<SettingsPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Force a full rebuild when page is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) => _invalidateSettings());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Fires when user returns from System Preferences
    if (state == AppLifecycleState.resumed) {
      _invalidateSettings();
    }
  }

  @override
  void didPush() => _invalidateSettings();

  @override
  void didPopNext() => _invalidateSettings();

  void _invalidateSettings() {
    // Invalidating forces the provider to call build() from scratch,
    // ensuring we always get fresh permission states from the OS.
    ref.invalidate(settingsControllerProvider);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeControllerProvider);
    final isDark = themeMode == ThemeMode.dark;
    final settings = ref.watch(settingsControllerProvider);

    // Once the controller finishes its initial async build, immediately
    // re-invalidate to snapshot the freshest OS permission state.
    ref.listen(settingsControllerProvider, (previous, next) {
      if (previous?.isLoading == true && next.hasValue) {
        // Don't invalidate again here — build() already fetched fresh permissions.
        // This listener is kept only for future extensibility.
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '設定',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 32),
                
                // --- General Settings Section ---
                _SectionHeader(title: '一般設定'),
                const SizedBox(height: 12),
                _SettingsCard(
                  children: [
                    // Theme Toggle
                    _SettingTile(
                      icon: isDark ? Icons.dark_mode : Icons.light_mode,
                      title: '深色模式',
                      subtitle: '切換應用程式的外觀風格',
                      trailing: _AppToggle(
                        value: isDark,
                        onChanged: (_) =>
                            ref.read(themeControllerProvider.notifier).toggleTheme(),
                        activeIcon: Icons.nightlight_round,
                        inactiveIcon: Icons.wb_sunny_rounded,
                      ),
                    ),
                    const Divider(height: 1, indent: 56),
                    
                    // Launch at Startup
                    settings.when(
                      data: (data) => _SettingTile(
                        icon: Icons.launch,
                        title: '開機啟動',
                        subtitle: '在電腦啟動時自動開啟 ZeroType',
                        trailing: Switch(
                          value: data.launchAtStartup,
                          onChanged: (val) => ref
                              .read(settingsControllerProvider.notifier)
                              .toggleLaunchAtStartup(val),
                        ),
                      ),
                      loading: () => const _LoadingTile(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const Divider(height: 1, indent: 56),
                    // Refinement enabled
                    settings.when(
                      data: (data) => _SettingTile(
                        icon: Icons.auto_fix_high,
                        title: '啟用文字優化',
                        subtitle:
                            '轉錄完成後再丟給聊天模型做格式化／錯字修正（在「模型」頁設定 provider 與模型）',
                        trailing: Switch(
                          value: data.refinementEnabled,
                          onChanged: (val) => ref
                              .read(settingsControllerProvider.notifier)
                              .toggleRefinementEnabled(val),
                        ),
                      ),
                      loading: () => const _LoadingTile(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const Divider(height: 1, indent: 56),
                    // History Retention Days
                    settings.when(
                      data: (data) => _SettingTile(
                        icon: Icons.history,
                        title: '歷史記錄保留時間',
                        subtitle: '超過保留天數的記錄將自動刪除',
                        trailing: SegmentedButton<int>(
                          segments: const [
                            ButtonSegment(value: 7, label: Text('7天')),
                            ButtonSegment(value: 14, label: Text('14天')),
                            ButtonSegment(value: 30, label: Text('30天')),
                          ],
                          selected: {data.historyRetentionDays},
                          onSelectionChanged: (selection) => ref
                              .read(settingsControllerProvider.notifier)
                              .setHistoryRetentionDays(selection.first),
                          style: const ButtonStyle(
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),
                      loading: () => const _LoadingTile(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const Divider(height: 1, indent: 56),
                    // Max Recording Duration
                    settings.when(
                      data: (data) => _SettingTile(
                        icon: Icons.timer_outlined,
                        title: '最長錄音時間',
                        subtitle: '超過此時長將自動停止並送出辨識',
                        trailing: SizedBox(
                          width: 200,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 140,
                                child: Slider(
                                  value: data.maxRecordingMinutes.toDouble(),
                                  min: 1,
                                  max: 5,
                                  divisions: 4,
                                  onChanged: (val) => ref
                                      .read(settingsControllerProvider.notifier)
                                      .setMaxRecordingMinutes(val.round()),
                                ),
                              ),
                              Text(
                                '${data.maxRecordingMinutes} 分鐘',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      loading: () => const _LoadingTile(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // --- Shortcut Section ---
                _SectionHeader(title: '快捷鍵'),
                const SizedBox(height: 12),
                _SettingsCard(
                  children: [
                    settings.when(
                      data: (data) => InkWell(
                        onTap: () => ref.read(settingsControllerProvider.notifier).startRecordingHotkey(),
                        borderRadius: BorderRadius.circular(16),
                        child: _SettingTile(
                          icon: Icons.keyboard,
                          title: '全局錄音快捷鍵',
                          subtitle: '按下此組合鍵即可開始/停止錄音',
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary.withAlpha(50),
                              ),
                            ),
                            child: _buildHotkeyDisplay(context, data.hotkey),
                          ),
                        ),
                      ),
                      loading: () => const _LoadingTile(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // --- Sound Section ---
                _SectionHeader(title: '音效'),
                const SizedBox(height: 12),
                _SettingsCard(
                  children: [
                    settings.when(
                      data: (data) => _SettingTile(
                        icon: Icons.volume_up,
                        title: '啟用音效',
                        subtitle: '開始與停止錄音時播放提示音',
                        trailing: Switch(
                          value: data.soundEnabled,
                          onChanged: (val) => ref
                              .read(settingsControllerProvider.notifier)
                              .toggleSound(val),
                        ),
                      ),
                      loading: () => const _LoadingTile(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const Divider(height: 1, indent: 56),
                    settings.when(
                      data: (data) => _SoundPickerTile(
                        icon: Icons.play_circle_outline,
                        title: '開始錄音音效',
                        subtitle: '按下快捷鍵開始錄音時播放',
                        selectedPath: data.startSound,
                        enabled: data.soundEnabled,
                        onChanged: (path) => ref
                            .read(settingsControllerProvider.notifier)
                            .setStartSound(path),
                      ),
                      loading: () => const _LoadingTile(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const Divider(height: 1, indent: 56),
                    settings.when(
                      data: (data) => _SoundPickerTile(
                        icon: Icons.stop_circle_outlined,
                        title: '停止錄音音效',
                        subtitle: '再次按下快捷鍵停止錄音時播放',
                        selectedPath: data.stopSound,
                        enabled: data.soundEnabled,
                        onChanged: (path) => ref
                            .read(settingsControllerProvider.notifier)
                            .setStopSound(path),
                      ),
                      loading: () => const _LoadingTile(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // --- System Permission Section ---
                _SectionHeader(title: '系統權限'),
                const SizedBox(height: 12),
                _SettingsCard(
                  children: [
                    if (!Platform.isWindows) ...[
                      settings.when(
                        data: (data) => _PermissionTile(
                          icon: Icons.accessibility_new,
                          title: '輔助使用權限',
                          subtitle: '自動貼上功能需要此權限以模擬鍵盤動作',
                          isAuthorized: data.isAccessibilityAuthorized,
                          onCheck: () => const MethodChannel('com.zerotype.app/permission')
                              .invokeMethod('openAccessibilitySettings'),
                        ),
                        loading: () => const _LoadingTile(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const Divider(height: 1, indent: 56),
                    ],
                    settings.when(
                      data: (data) => _PermissionTile(
                        icon: Icons.mic,
                        title: '麥克風權限',
                        subtitle: '語音辨識功能需要存取你的麥克風',
                        isAuthorized: data.isMicrophoneAuthorized,
                        onCheck: () => const MethodChannel('com.zerotype.app/permission')
                            .invokeMethod('openMicrophoneSettings'),
                      ),
                      loading: () => const _LoadingTile(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // --- Hotkey Recorder Overlay ---
          settings.maybeWhen(
            data: (data) => data.isRecordingHotkey 
              ? _HotkeyRecorderOverlay(
                  onSave: (keys) => ref.read(settingsControllerProvider.notifier).saveHotkey(keys),
                  onClose: () => ref.read(settingsControllerProvider.notifier).stopRecordingHotkey(),
                )
              : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildHotkeyDisplay(BuildContext context, HotKey hotkey) {
    final List<Widget> widgets = [];
    
    if (hotkey.modifiers != null) {
      for (final mod in hotkey.modifiers!) {
        final label = _modifierLabel(mod);
        if (label.isNotEmpty) {
          if (widgets.isNotEmpty) widgets.add(const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('+')));
          widgets.add(_KeyBadge(label: label));
        }
      }
    }

    String keyLabel = 'Key';
    if (hotkey.key is PhysicalKeyboardKey) {
      final physKey = hotkey.key as PhysicalKeyboardKey;
      keyLabel = physKey.debugName ?? 'Key';
      if (keyLabel.startsWith('Key ')) keyLabel = keyLabel.substring(4);
    } else if (hotkey.key is LogicalKeyboardKey) {
      keyLabel = (hotkey.key as LogicalKeyboardKey).keyLabel;
    }

    if (hotkey.key == PhysicalKeyboardKey.space || hotkey.key == LogicalKeyboardKey.space) {
      keyLabel = 'Space';
    }
    
    if (widgets.isNotEmpty) widgets.add(const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('+')));
    widgets.add(_KeyBadge(label: keyLabel.toUpperCase()));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

}

class _HotkeyRecorderOverlay extends StatefulWidget {
  final Function(List<PhysicalKeyboardKey>) onSave;
  final VoidCallback onClose;
  const _HotkeyRecorderOverlay({required this.onSave, required this.onClose});

  @override
  State<_HotkeyRecorderOverlay> createState() => _HotkeyRecorderOverlayState();
}

class _HotkeyRecorderOverlayState extends State<_HotkeyRecorderOverlay> {
  final FocusNode _focusNode = FocusNode();
  final Set<PhysicalKeyboardKey> _currentlyHeldKeys = {};
  final List<PhysicalKeyboardKey> _recordedKeys = [];
  String _displayText = '等待輸入...';
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _updateDisplayText() {
    if (_recordedKeys.isEmpty) {
      setState(() => _displayText = '等待輸入...');
      return;
    }

    final List<String> parts = [];
    final sortedKeys = List<PhysicalKeyboardKey>.from(_recordedKeys);
    
    // Sort logic
    sortedKeys.sort((a, b) {
      int score(PhysicalKeyboardKey k) {
        if (_isMeta(k)) return 0;
        if (_isControl(k)) return 1;
        if (_isAlt(k)) return 2;
        if (_isShift(k)) return 3;
        return 4;
      }
      return score(a).compareTo(score(b));
    });

    for (final key in sortedKeys) {
      if (_isMeta(key)) {
        final label = _modifierLabel(HotKeyModifier.meta);
        if (!parts.contains(label)) parts.add(label);
      } else if (_isControl(key)) {
        final label = _modifierLabel(HotKeyModifier.control);
        if (!parts.contains(label)) parts.add(label);
      } else if (_isAlt(key)) {
        final label = _modifierLabel(HotKeyModifier.alt);
        if (!parts.contains(label)) parts.add(label);
      } else if (_isShift(key)) {
        final label = _modifierLabel(HotKeyModifier.shift);
        if (!parts.contains(label)) parts.add(label);
      } else if (key == PhysicalKeyboardKey.space) {
        parts.add('Space');
      } else {
        // More robust labeling for PhysicalKeyboardKey
        String label = key.debugName ?? 'Key';
        if (label.startsWith('Key ')) {
          label = label.substring(4);
        }
        
        // Handle specific cases or ensure it's uppercase
        if (label.length == 1) {
          label = label.toUpperCase();
        }
        parts.add(label);
      }
    }

    setState(() => _displayText = parts.join(' + '));
  }

  bool _isModifier(PhysicalKeyboardKey key) => _isMeta(key) || _isControl(key) || _isAlt(key) || _isShift(key);
  bool _isMeta(PhysicalKeyboardKey key) => key == PhysicalKeyboardKey.metaLeft || key == PhysicalKeyboardKey.metaRight;
  bool _isControl(PhysicalKeyboardKey key) => key == PhysicalKeyboardKey.controlLeft || key == PhysicalKeyboardKey.controlRight;
  bool _isAlt(PhysicalKeyboardKey key) => key == PhysicalKeyboardKey.altLeft || key == PhysicalKeyboardKey.altRight;
  bool _isShift(PhysicalKeyboardKey key) => key == PhysicalKeyboardKey.shiftLeft || key == PhysicalKeyboardKey.shiftRight;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent) {
            if (_currentlyHeldKeys.isEmpty) {
              _recordedKeys.clear();
              _isFinished = false;
            }

            if (!_recordedKeys.contains(event.physicalKey)) {
              _recordedKeys.add(event.physicalKey);
            }
            _currentlyHeldKeys.add(event.physicalKey);
            _updateDisplayText();
            
            if (event.physicalKey == PhysicalKeyboardKey.escape && _currentlyHeldKeys.length == 1) {
              _recordedKeys.clear();
              widget.onClose();
              return;
            }
          } else if (event is KeyUpEvent) {
            _currentlyHeldKeys.remove(event.physicalKey);
            if (_currentlyHeldKeys.isEmpty) {
              _isFinished = true;
            }
          }
        },
        child: Container(
          color: Colors.black.withOpacity(0.9),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.keyboard, color: Colors.orangeAccent, size: 64),
                    const SizedBox(height: 24),
                    Text(
                      '錄製快捷鍵組合',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 32),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _recordedKeys.isNotEmpty ? Colors.orangeAccent.withOpacity(0.5) : Colors.white.withOpacity(0.1),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orangeAccent.withOpacity(_recordedKeys.isNotEmpty ? 0.1 : 0),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Text(
                        _displayText,
                        style: TextStyle(
                          color: _recordedKeys.isNotEmpty ? Colors.orangeAccent : Colors.white24,
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      '請「同時按住」組合鍵，放開後可重新輸入',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 64),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton(
                          onPressed: widget.onClose,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white60,
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('取消', style: TextStyle(fontSize: 16)),
                        ),
                        const SizedBox(width: 24),
                        if (_recordedKeys.isNotEmpty)
                          ElevatedButton(
                            onPressed: () => widget.onSave(_recordedKeys),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 10,
                            ),
                            child: const Text(
                              '儲存設定',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 40,
                right: 40,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54, size: 36),
                  onPressed: widget.onClose,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isAuthorized;
  final VoidCallback onCheck;

  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isAuthorized,
    required this.onCheck,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isAuthorized ? Colors.green : Colors.red,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isAuthorized ? Colors.green : Colors.red).withOpacity(0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isAuthorized ? '已授權' : '未授權',
            style: TextStyle(
              color: isAuthorized ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton(
            onPressed: onCheck,
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('打開設定'),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Ensure vertical center alignment
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _AppToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData activeIcon;
  final IconData inactiveIcon;

  const _AppToggle({
    required this.value,
    required this.onChanged,
    required this.activeIcon,
    required this.inactiveIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => onChanged(!value),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(
            value ? activeIcon : inactiveIcon,
            size: 20,
            color: value ? Colors.orangeAccent : Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _KeyBadge extends StatelessWidget {
  final String label;
  const _KeyBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cs.primary.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: cs.primary,
        ),
      ),
    );
  }
}

class _LoadingTile extends StatelessWidget {
  const _LoadingTile();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _SoundPickerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String selectedPath;
  final bool enabled;
  final ValueChanged<String> onChanged;

  const _SoundPickerTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selectedPath,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final effectivePath = kSystemSoundLabels.containsKey(selectedPath)
        ? selectedPath
        : (kSystemSoundLabels.containsKey(kDefaultStartSound)
            ? kDefaultStartSound
            : kSystemSoundLabels.keys.first);
    final selectedLabel = kSystemSoundLabels[effectivePath] ?? '';

    return _SettingTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: effectivePath,
              underline: const SizedBox.shrink(),
              borderRadius: BorderRadius.circular(12),
              selectedItemBuilder: (_) => kSystemSoundLabels.entries.map((e) {
                return Center(
                  child: Text(
                    e.value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                    ),
                  ),
                );
              }).toList(),
              items: kSystemSoundLabels.entries.map((e) {
                return DropdownMenuItem<String>(
                  value: e.key,
                  child: Text(e.value, style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
              onChanged: enabled
                  ? (path) {
                      if (path != null) onChanged(path);
                    }
                  : null,
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: '預覽「$selectedLabel」',
              icon: Icon(Icons.play_arrow_rounded, color: cs.primary, size: 20),
              onPressed: enabled
                  ? () => getIt<SoundService>().playPreview(effectivePath)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
