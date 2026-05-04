// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prompt_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(promptRepository)
final promptRepositoryProvider = PromptRepositoryProvider._();

final class PromptRepositoryProvider
    extends
        $FunctionalProvider<
          PromptRepository,
          PromptRepository,
          PromptRepository
        >
    with $Provider<PromptRepository> {
  PromptRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'promptRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$promptRepositoryHash();

  @$internal
  @override
  $ProviderElement<PromptRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PromptRepository create(Ref ref) {
    return promptRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PromptRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PromptRepository>(value),
    );
  }
}

String _$promptRepositoryHash() => r'b86395b75ee3d4a369bd575c590c4da54e548c6a';

@ProviderFor(SpeechPromptController)
final speechPromptControllerProvider = SpeechPromptControllerProvider._();

final class SpeechPromptControllerProvider
    extends $AsyncNotifierProvider<SpeechPromptController, String> {
  SpeechPromptControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'speechPromptControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$speechPromptControllerHash();

  @$internal
  @override
  SpeechPromptController create() => SpeechPromptController();
}

String _$speechPromptControllerHash() =>
    r'2c39484be308617c338b1d0b549757a1b838c1e1';

abstract class _$SpeechPromptController extends $AsyncNotifier<String> {
  FutureOr<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String>, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String>, String>,
              AsyncValue<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(RefinementPromptController)
final refinementPromptControllerProvider =
    RefinementPromptControllerProvider._();

final class RefinementPromptControllerProvider
    extends $AsyncNotifierProvider<RefinementPromptController, String> {
  RefinementPromptControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'refinementPromptControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$refinementPromptControllerHash();

  @$internal
  @override
  RefinementPromptController create() => RefinementPromptController();
}

String _$refinementPromptControllerHash() =>
    r'adee0c32bf7696254a613619da6890b3e173fb42';

abstract class _$RefinementPromptController extends $AsyncNotifier<String> {
  FutureOr<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String>, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String>, String>,
              AsyncValue<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
