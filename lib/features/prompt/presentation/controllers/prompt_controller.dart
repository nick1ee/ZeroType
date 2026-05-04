import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zero_type/core/di/injection.dart';
import 'package:zero_type/features/prompt/data/repositories/prompt_repository_impl.dart';
import 'package:zero_type/features/prompt/domain/repositories/prompt_repository.dart';

part 'prompt_controller.g.dart';

@riverpod
PromptRepository promptRepository(Ref ref) =>
    PromptRepositoryImpl(prefs: getIt<SharedPreferences>());

@riverpod
class SpeechPromptController extends _$SpeechPromptController {
  @override
  Future<String> build() async {
    final repo = ref.watch(promptRepositoryProvider);
    return repo.getSpeechPrompt();
  }

  Future<String> save(String prompt) async {
    final repo = ref.read(promptRepositoryProvider);
    final newVal = await repo.saveSpeechPrompt(prompt);
    ref.invalidateSelf();
    return newVal;
  }

  Future<String> resetToDefault() async {
    final repo = ref.read(promptRepositoryProvider);
    final newVal = await repo.resetSpeechPrompt();
    ref.invalidateSelf();
    return newVal;
  }
}

@riverpod
class RefinementPromptController extends _$RefinementPromptController {
  @override
  Future<String> build() async {
    final repo = ref.watch(promptRepositoryProvider);
    return repo.getRefinementPrompt();
  }

  Future<String> save(String prompt) async {
    final repo = ref.read(promptRepositoryProvider);
    final newVal = await repo.saveRefinementPrompt(prompt);
    ref.invalidateSelf();
    return newVal;
  }

  Future<String> resetToDefault() async {
    final repo = ref.read(promptRepositoryProvider);
    final newVal = await repo.resetRefinementPrompt();
    ref.invalidateSelf();
    return newVal;
  }
}

