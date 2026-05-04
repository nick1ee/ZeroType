import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zero_type/features/prompt/presentation/controllers/prompt_controller.dart';
import 'package:zero_type/features/prompt/presentation/widgets/prompt_editor.dart';

@RoutePage()
class PromptPage extends ConsumerStatefulWidget {
  const PromptPage({super.key});

  @override
  ConsumerState<PromptPage> createState() => _PromptPageState();
}

class _PromptPageState extends ConsumerState<PromptPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final speechPrompt = ref.watch(speechPromptControllerProvider);
    final refinementPrompt = ref.watch(refinementPromptControllerProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding:
            const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '提示詞',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '自訂發送給 AI 的系統提示詞',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withAlpha(150),
                  ),
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: cs.primary,
              unselectedLabelColor: cs.onSurface.withAlpha(150),
              indicatorColor: cs.primary,
              tabs: const [
                Tab(text: '語音辨識'),
                Tab(text: '文字優化'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  PromptEditor(
                    title: '語音辨識提示詞',
                    subtitle: '提供給語音辨識模型的補充指令',
                    icon: Icons.mic,
                    value: speechPrompt.value ?? '',
                    isLoading: speechPrompt.isLoading,
                    onSave: (text) => ref
                        .read(speechPromptControllerProvider.notifier)
                        .save(text),
                    onReset: () => ref
                        .read(speechPromptControllerProvider.notifier)
                        .resetToDefault(),
                  ),
                  PromptEditor(
                    title: '文字優化提示詞',
                    subtitle: '轉錄後送進 LLM 做格式化／錯字修正用的指令',
                    icon: Icons.auto_fix_high,
                    value: refinementPrompt.value ?? '',
                    isLoading: refinementPrompt.isLoading,
                    onSave: (text) => ref
                        .read(refinementPromptControllerProvider.notifier)
                        .save(text),
                    onReset: () => ref
                        .read(refinementPromptControllerProvider.notifier)
                        .resetToDefault(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
