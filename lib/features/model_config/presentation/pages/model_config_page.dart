import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/model_config_controller.dart';
import '../../domain/entities/ai_provider.dart';

@RoutePage()
class ModelConfigPage extends ConsumerWidget {
  const ModelConfigPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providersAsync = ref.watch(providersConfigProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: providersAsync.when(
        data: (config) => SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '模型',
                style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '設定語音辨識所使用的模型與 API Key',
                style: tt.bodyMedium?.copyWith(color: cs.onSurface.withAlpha(150)),
              ),
              const SizedBox(height: 32),
              
              _ConfigSection(
                title: '語音辨識',
                isRequired: true,
                child: _SpeechConfigSection(providers: config.speechRecognition),
              ),
              const SizedBox(height: 24),
              _ConfigSection(
                title: '文字優化（可選）',
                isRequired: false,
                child:
                    _RefinementConfigSection(providers: config.speechRecognition),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('載入失敗: $err')),
      ),
    );
  }
}

class _ConfigSection extends StatefulWidget {
  const _ConfigSection({
    required this.title,
    required this.isRequired,
    required this.child,
  });

  final String title;
  final bool isRequired;
  final Widget child;

  @override
  State<_ConfigSection> createState() => _ConfigSectionState();
}

class _ConfigSectionState extends State<_ConfigSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(100),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.onSurface.withAlpha(20)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    widget.title,
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (widget.isRequired) ...[
                    const SizedBox(width: 4),
                    const Text('*', style: TextStyle(color: Colors.redAccent, fontSize: 18)),
                  ],
                  const Spacer(),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: cs.onSurface.withAlpha(150),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: widget.child,
            ),
          ],
        ],
      ),
    );
  }
}

class _SpeechConfigSection extends ConsumerWidget {
  const _SpeechConfigSection({required this.providers});
  final List<AiProvider> providers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(speechProviderControllerProvider);
    final cs = Theme.of(context).colorScheme;

    return stateAsync.when(
      data: (state) {
        final selectedProvider = providers.firstWhere(
          (p) => p.id == state.providerId,
          orElse: () => providers.first,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('選擇 Provider', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: providers.map((p) {
                final isSelected = p.id == state.providerId;
                return ChoiceChip(
                  label: Text(p.name),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) {
                      ref.read(speechProviderControllerProvider.notifier).selectProvider(p.id);
                    }
                  },
                  backgroundColor: cs.surface,
                  selectedColor: cs.primary.withAlpha(50),
                  labelStyle: TextStyle(
                    color: isSelected ? cs.primary : cs.onSurface.withAlpha(150),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? cs.primary : cs.onSurface.withAlpha(30),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            _ApiKeyInput(
              providerId: state.providerId ?? '',
              initialValue: state.apiKey ?? '',
              onSave: (val) => ref.read(speechProviderControllerProvider.notifier).saveApiKey(val),
            ),
            if (state.providerId == 'litellm') ...[
              const SizedBox(height: 24),
              _LiteLLMEndpointInput(
                initialValue: state.customEndpoint ?? '',
                onSave: (val) => ref
                    .read(speechProviderControllerProvider.notifier)
                    .saveCustomEndpoint(val),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('選擇模型', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                const Text('*', style: TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Text('(必填)', style: TextStyle(color: Colors.redAccent.withAlpha(150), fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            if (state.providerId == 'litellm')
              _LiteLLMModelPicker(
                baseUrl: state.customEndpoint ?? '',
                apiKey: state.apiKey ?? '',
                selectedModelId: state.modelId,
                onChanged: (val) {
                  if (val != null) {
                    ref
                        .read(speechProviderControllerProvider.notifier)
                        .selectModel(val);
                  }
                },
              )
            else
              _ModelDropdown(
                models: selectedProvider.models,
                selectedModelId: state.modelId,
                onChanged: (val) {
                  if (val != null) {
                    ref.read(speechProviderControllerProvider.notifier).selectModel(val);
                  }
                },
              ),
            if (state.providerId != 'litellm') ...[
              const SizedBox(height: 24),
              _AdvancedConfigSection(
                providerId: state.providerId ?? '',
                customEndpoint: state.customEndpoint ?? '',
                onSaveCustomEndpoint: (val) => ref.read(speechProviderControllerProvider.notifier).saveCustomEndpoint(val),
              ),
            ],
          ],
        );
      },
      loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
      error: (err, _) => Text('錯誤: $err'),
    );
  }
}


class _RefinementConfigSection extends ConsumerWidget {
  const _RefinementConfigSection({required this.providers});
  final List<AiProvider> providers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(refinementProviderControllerProvider);
    final cs = Theme.of(context).colorScheme;

    return stateAsync.when(
      data: (state) {
        final selectedProvider = providers.firstWhere(
          (p) => p.id == state.providerId,
          orElse: () => providers.first,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '把語音辨識結果再丟給一個聊天模型做格式化、錯字修正、條列整理。'
              '需要在「設定」頁打開「啟用文字優化」才會生效。',
              style: TextStyle(
                color: cs.onSurface.withAlpha(150),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            const Text('選擇 Provider', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: providers.map((p) {
                final isSelected = p.id == state.providerId;
                return ChoiceChip(
                  label: Text(p.name),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) {
                      ref
                          .read(refinementProviderControllerProvider.notifier)
                          .selectProvider(p.id);
                    }
                  },
                  backgroundColor: cs.surface,
                  selectedColor: cs.primary.withAlpha(50),
                  labelStyle: TextStyle(
                    color: isSelected ? cs.primary : cs.onSurface.withAlpha(150),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? cs.primary : cs.onSurface.withAlpha(30),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            _ApiKeyInput(
              providerId: state.providerId ?? '',
              initialValue: state.apiKey ?? '',
              onSave: (val) => ref
                  .read(refinementProviderControllerProvider.notifier)
                  .saveApiKey(val),
            ),
            if (state.providerId == 'litellm') ...[
              const SizedBox(height: 24),
              _LiteLLMEndpointInput(
                initialValue: state.customEndpoint ?? '',
                onSave: (val) => ref
                    .read(refinementProviderControllerProvider.notifier)
                    .saveCustomEndpoint(val),
              ),
            ],
            const SizedBox(height: 24),
            const Text('選擇模型', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            if (state.providerId == 'litellm')
              _LiteLLMModelPicker(
                baseUrl: state.customEndpoint ?? '',
                apiKey: state.apiKey ?? '',
                selectedModelId: state.modelId,
                isRefinement: true,
                onChanged: (val) {
                  if (val != null) {
                    ref
                        .read(refinementProviderControllerProvider.notifier)
                        .selectModel(val);
                  }
                },
              )
            else
              _ModelDropdown(
                models: selectedProvider.models,
                selectedModelId: state.modelId,
                onChanged: (val) {
                  if (val != null) {
                    ref
                        .read(refinementProviderControllerProvider.notifier)
                        .selectModel(val);
                  }
                },
              ),
            if (state.providerId != 'litellm') ...[
              const SizedBox(height: 24),
              _AdvancedConfigSection(
                providerId: state.providerId ?? '',
                customEndpoint: state.customEndpoint ?? '',
                onSaveCustomEndpoint: (val) => ref
                    .read(refinementProviderControllerProvider.notifier)
                    .saveCustomEndpoint(val),
              ),
            ],
          ],
        );
      },
      loading: () =>
          const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
      error: (err, _) => Text('錯誤: $err'),
    );
  }
}

class _ApiKeyInput extends StatefulWidget {
  const _ApiKeyInput({
    required this.providerId,
    required this.initialValue,
    required this.onSave,
  });

  final String providerId;
  final String initialValue;
  final Function(String) onSave;

  @override
  State<_ApiKeyInput> createState() => _ApiKeyInputState();
}

class _ApiKeyInputState extends State<_ApiKeyInput> {
  late final TextEditingController _controller;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_ApiKeyInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.providerId != oldWidget.providerId || widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('API Key', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            const Text('*', style: TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Text('(必填)', style: TextStyle(color: Colors.redAccent.withAlpha(150), fontSize: 12)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  hintText: '輸入 ${widget.providerId} API Key',
                  hintStyle: TextStyle(color: cs.onSurface.withAlpha(80)),
                  filled: true,
                  fillColor: cs.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.onSurface.withAlpha(30)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.onSurface.withAlpha(30)),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off, size: 20),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  ),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                widget.onSave(_controller.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('API Key 已儲存'), duration: Duration(seconds: 1)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              child: const Text('儲存'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ModelDropdown extends StatelessWidget {
  const _ModelDropdown({
    required this.models,
    required this.selectedModelId,
    required this.onChanged,
  });

  final List<AiModel> models;
  final String? selectedModelId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.onSurface.withAlpha(30)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: models.any((m) => m.id == selectedModelId) ? selectedModelId : null,
          isExpanded: true,
          hint: const Text('選擇一個模型'),
          items: models.map((m) {
            return DropdownMenuItem(
              value: m.id,
              child: Text(m.name),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _CustomEndpointInput extends StatefulWidget {
  const _CustomEndpointInput({
    required this.providerId,
    required this.initialValue,
    required this.onSave,
  });

  final String providerId;
  final String initialValue;
  final Function(String) onSave;

  @override
  State<_CustomEndpointInput> createState() => _CustomEndpointInputState();
}

class _CustomEndpointInputState extends State<_CustomEndpointInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_CustomEndpointInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.providerId != oldWidget.providerId || widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('自建模型接口', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: '非必填',
                  hintStyle: TextStyle(color: cs.onSurface.withAlpha(80)),
                  filled: true,
                  fillColor: cs.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.onSurface.withAlpha(30)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.onSurface.withAlpha(30)),
                  ),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                widget.onSave(_controller.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('接口設定已儲存'), duration: Duration(seconds: 1)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              child: const Text('儲存'),
            ),
          ],
        ),
      ],
    );
  }
}

class _LiteLLMEndpointInput extends StatefulWidget {
  const _LiteLLMEndpointInput({
    required this.initialValue,
    required this.onSave,
  });

  final String initialValue;
  final Function(String) onSave;

  @override
  State<_LiteLLMEndpointInput> createState() => _LiteLLMEndpointInputState();
}

class _LiteLLMEndpointInputState extends State<_LiteLLMEndpointInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_LiteLLMEndpointInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Proxy Base URL', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            const Text('*', style: TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Text('(必填)', style: TextStyle(color: Colors.redAccent.withAlpha(150), fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '例如：https://litellm.example.com（不要含 /v1）',
          style: TextStyle(color: cs.onSurface.withAlpha(120), fontSize: 12),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'https://litellm.example.com',
                  hintStyle: TextStyle(color: cs.onSurface.withAlpha(80)),
                  filled: true,
                  fillColor: cs.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.onSurface.withAlpha(30)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.onSurface.withAlpha(30)),
                  ),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                widget.onSave(_controller.text.trim());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Proxy URL 已儲存'), duration: Duration(seconds: 1)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              child: const Text('儲存'),
            ),
          ],
        ),
      ],
    );
  }
}

class _LiteLLMModelPicker extends ConsumerWidget {
  const _LiteLLMModelPicker({
    required this.baseUrl,
    required this.apiKey,
    required this.selectedModelId,
    required this.onChanged,
    this.isRefinement = false,
  });

  final String baseUrl;
  final String apiKey;
  final String? selectedModelId;
  final ValueChanged<String?> onChanged;
  final bool isRefinement;

  bool get _canFetch => baseUrl.isNotEmpty && apiKey.isNotEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final modelsAsync = isRefinement
        ? ref.watch(dynamicRefinementModelsControllerProvider('litellm'))
        : ref.watch(dynamicModelsControllerProvider('litellm'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildDropdown(context, modelsAsync.value ?? const [])),
            const SizedBox(width: 8),
            IconButton(
              tooltip: _canFetch
                  ? '從 /v1/models 重新抓取模型清單'
                  : '需先填入 Proxy URL 與 API Key',
              icon: modelsAsync.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              onPressed: _canFetch && !modelsAsync.isLoading
                  ? () async {
                      if (isRefinement) {
                        await ref
                            .read(dynamicRefinementModelsControllerProvider(
                                    'litellm')
                                .notifier)
                            .refresh(
                              providerId: 'litellm',
                              baseUrl: baseUrl,
                              apiKey: apiKey,
                            );
                      } else {
                        await ref
                            .read(dynamicModelsControllerProvider('litellm')
                                .notifier)
                            .refresh(
                              providerId: 'litellm',
                              baseUrl: baseUrl,
                              apiKey: apiKey,
                            );
                      }
                      if (context.mounted) {
                        final newState = isRefinement
                            ? ref.read(dynamicRefinementModelsControllerProvider(
                                'litellm'))
                            : ref.read(
                                dynamicModelsControllerProvider('litellm'));
                        final msg = newState.hasError
                            ? '抓取失敗：${newState.error}'
                            : '已更新 ${newState.value?.length ?? 0} 個模型';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(msg),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  : null,
            ),
          ],
        ),
        if (modelsAsync.hasError) ...[
          const SizedBox(height: 8),
          Text(
            '抓取錯誤：${modelsAsync.error}',
            style: TextStyle(color: Colors.redAccent.withAlpha(200), fontSize: 12),
          ),
        ] else if ((modelsAsync.value ?? const []).isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            _canFetch
                ? '尚未抓取模型清單，按右側重新整理。'
                : '請先填寫 Proxy Base URL 與 API Key，再按右側重新整理。',
            style: TextStyle(color: cs.onSurface.withAlpha(120), fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _buildDropdown(BuildContext context, List<AiModel> models) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.onSurface.withAlpha(30)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: models.any((m) => m.id == selectedModelId)
              ? selectedModelId
              : null,
          isExpanded: true,
          hint: Text(
            models.isEmpty ? '尚未抓取模型清單' : '選擇一個模型',
          ),
          items: models
              .map((m) => DropdownMenuItem(
                    value: m.id,
                    child: Text(m.id),
                  ))
              .toList(),
          onChanged: models.isEmpty ? null : onChanged,
        ),
      ),
    );
  }
}

class _AdvancedConfigSection extends StatelessWidget {
  const _AdvancedConfigSection({
    required this.providerId,
    required this.customEndpoint,
    required this.onSaveCustomEndpoint,
  });

  final String providerId;
  final String customEndpoint;
  final Function(String) onSaveCustomEndpoint;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: const Text(
          '進階設定',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        tilePadding: EdgeInsets.zero,
        expandedAlignment: Alignment.centerLeft,
        children: [
          _CustomEndpointInput(
            providerId: providerId,
            initialValue: customEndpoint,
            onSave: onSaveCustomEndpoint,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
