import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:zero_type/core/di/injection.dart';
import 'package:zero_type/core/router/app_router.dart';
import 'package:zero_type/features/history/presentation/controllers/history_controller.dart';
import 'package:zero_type/shared/widgets/recording_overlay.dart';

@RoutePage()
class MainShellPage extends ConsumerStatefulWidget {
  const MainShellPage({super.key});

  @override
  ConsumerState<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends ConsumerState<MainShellPage> {
  static const String _permissionPromptKey = 'has_shown_permission_prompt_v1';
  bool _needsPermissionPrompt = false;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = getIt<SharedPreferences>();
    if (!prefs.containsKey(_permissionPromptKey)) {
      await prefs.setBool(_permissionPromptKey, true);
      if (mounted) setState(() => _needsPermissionPrompt = true);
    }
  }

  void _showPermissionPrompt(BuildContext context, TabsRouter tabsRouter) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.security_outlined,
                color: Theme.of(context).colorScheme.primary, size: 22),
            const SizedBox(width: 8),
            const Text('需要系統權限'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ZeroType 需要以下兩項系統權限才能正常運作：',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            _PermissionItem(
              icon: Icons.accessibility_new,
              title: '輔助使用',
              description: '系統設定 > 隱私權與安全性 > 輔助使用',
              note: '用於自動貼上辨識結果',
            ),
            const SizedBox(height: 12),
            _PermissionItem(
              icon: Icons.mic,
              title: '麥克風',
              description: '系統設定 > 隱私權與安全性 > 麥克風',
              note: '用於錄製語音',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('稍後再說'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              tabsRouter.setActiveIndex(4); // Settings is now index 4
            },
            child: const Text('前往設定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildMain(),
        const RecordingOverlay(),
      ],
    );
  }

  Widget _buildMain() {
    return AutoTabsRouter(
      routes: const [
        ModelConfigRoute(),   // 0 模型
        PromptRoute(),         // 1 提示詞
        DictionaryRoute(),     // 2 字典檔
        HistoryRoute(),        // 3 歷史
        SettingsRoute(),       // 4 設定
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        if (_needsPermissionPrompt && !_dialogShown) {
          _dialogShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _showPermissionPrompt(context, tabsRouter);
          });
        }

        return Scaffold(
          body: Column(
            children: [
              const _TitleBar(),
              const Divider(height: 1, thickness: 1),
              Expanded(
                child: Row(
                  children: [
                    NavigationRail(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      selectedIndex: tabsRouter.activeIndex,
                      onDestinationSelected: (index) {
                        if (index == 3) {
                          ref.invalidate(historyControllerProvider);
                          ref.invalidate(historyStatsProvider);
                        }
                        tabsRouter.setActiveIndex(index);
                      },
                      labelType: NavigationRailLabelType.all,
                      leading: const SizedBox(height: 16),
                      selectedIconTheme: IconThemeData(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.tune_outlined),
                          selectedIcon: Icon(Icons.tune),
                          label: Text('模型'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.edit_note_outlined),
                          selectedIcon: Icon(Icons.edit_note),
                          label: Text('提示詞'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.book_outlined),
                          selectedIcon: Icon(Icons.book),
                          label: Text('字典檔'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.history_outlined),
                          selectedIcon: Icon(Icons.history),
                          label: Text('歷史'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.settings_outlined),
                          selectedIcon: Icon(Icons.settings),
                          label: Text('設定'),
                        ),
                      ],
                    ),
                    const VerticalDivider(thickness: 1, width: 1),
                    Expanded(child: child),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TitleBar extends StatelessWidget {
  const _TitleBar();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 44,
      color: cs.surface,
      child: Row(
        children: [
          // Drag region — entire centre area is grabbable for moving the window.
          // Buttons sit at the right end and intercept their own pointer events.
          Expanded(
            child: DragToMoveArea(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Zero Type',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                ),
              ),
            ),
          ),
          _WindowControlButton(
            icon: Icons.remove,
            tooltip: '最小化',
            onTap: () => windowManager.minimize(),
          ),
          _WindowControlButton(
            icon: Icons.crop_square,
            tooltip: '最大化／還原',
            onTap: () async {
              if (await windowManager.isMaximized()) {
                await windowManager.unmaximize();
              } else {
                await windowManager.maximize();
              }
            },
          ),
          _WindowControlButton(
            icon: Icons.close,
            tooltip: '關閉',
            isClose: true,
            onTap: () => windowManager.close(),
          ),
        ],
      ),
    );
  }
}

class _WindowControlButton extends StatefulWidget {
  const _WindowControlButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isClose = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isClose;

  @override
  State<_WindowControlButton> createState() => _WindowControlButtonState();
}

class _WindowControlButtonState extends State<_WindowControlButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hoverColor = widget.isClose
        ? const Color(0xFFE81123)
        : cs.onSurface.withValues(alpha: 0.08);
    final iconColor = widget.isClose && _hovering ? Colors.white : cs.onSurface;
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 46,
            height: 44,
            color: _hovering ? hoverColor : Colors.transparent,
            alignment: Alignment.center,
            child: Icon(widget.icon, size: 16, color: iconColor),
          ),
        ),
      ),
    );
  }
}

class _PermissionItem extends StatelessWidget {
  const _PermissionItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.note,
  });

  final IconData icon;
  final String title;
  final String description;
  final String note;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: colorScheme.onPrimaryContainer),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 2),
              Text(description,
                  style: TextStyle(
                      fontSize: 12, color: colorScheme.onSurfaceVariant)),
              Text(note,
                  style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7))),
            ],
          ),
        ),
      ],
    );
  }
}
