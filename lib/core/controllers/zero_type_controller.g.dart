// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zero_type_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ZeroTypeController)
final zeroTypeControllerProvider = ZeroTypeControllerProvider._();

final class ZeroTypeControllerProvider
    extends $NotifierProvider<ZeroTypeController, ZeroTypeState> {
  ZeroTypeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'zeroTypeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$zeroTypeControllerHash();

  @$internal
  @override
  ZeroTypeController create() => ZeroTypeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ZeroTypeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ZeroTypeState>(value),
    );
  }
}

String _$zeroTypeControllerHash() =>
    r'bbc8298cecb8bc86652717576076330b34dd6083';

abstract class _$ZeroTypeController extends $Notifier<ZeroTypeState> {
  ZeroTypeState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ZeroTypeState, ZeroTypeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ZeroTypeState, ZeroTypeState>,
              ZeroTypeState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
