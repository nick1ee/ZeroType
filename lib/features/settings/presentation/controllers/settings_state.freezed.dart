// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingsState {

 bool get launchAtStartup; HotKey get hotkey; bool get isAccessibilityAuthorized; bool get isMicrophoneAuthorized; bool get isRecordingHotkey; bool get soundEnabled; String get startSound; String get stopSound; int get historyRetentionDays; int get maxRecordingMinutes; bool get refinementEnabled;
/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsStateCopyWith<SettingsState> get copyWith => _$SettingsStateCopyWithImpl<SettingsState>(this as SettingsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsState&&(identical(other.launchAtStartup, launchAtStartup) || other.launchAtStartup == launchAtStartup)&&(identical(other.hotkey, hotkey) || other.hotkey == hotkey)&&(identical(other.isAccessibilityAuthorized, isAccessibilityAuthorized) || other.isAccessibilityAuthorized == isAccessibilityAuthorized)&&(identical(other.isMicrophoneAuthorized, isMicrophoneAuthorized) || other.isMicrophoneAuthorized == isMicrophoneAuthorized)&&(identical(other.isRecordingHotkey, isRecordingHotkey) || other.isRecordingHotkey == isRecordingHotkey)&&(identical(other.soundEnabled, soundEnabled) || other.soundEnabled == soundEnabled)&&(identical(other.startSound, startSound) || other.startSound == startSound)&&(identical(other.stopSound, stopSound) || other.stopSound == stopSound)&&(identical(other.historyRetentionDays, historyRetentionDays) || other.historyRetentionDays == historyRetentionDays)&&(identical(other.maxRecordingMinutes, maxRecordingMinutes) || other.maxRecordingMinutes == maxRecordingMinutes)&&(identical(other.refinementEnabled, refinementEnabled) || other.refinementEnabled == refinementEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,launchAtStartup,hotkey,isAccessibilityAuthorized,isMicrophoneAuthorized,isRecordingHotkey,soundEnabled,startSound,stopSound,historyRetentionDays,maxRecordingMinutes,refinementEnabled);

@override
String toString() {
  return 'SettingsState(launchAtStartup: $launchAtStartup, hotkey: $hotkey, isAccessibilityAuthorized: $isAccessibilityAuthorized, isMicrophoneAuthorized: $isMicrophoneAuthorized, isRecordingHotkey: $isRecordingHotkey, soundEnabled: $soundEnabled, startSound: $startSound, stopSound: $stopSound, historyRetentionDays: $historyRetentionDays, maxRecordingMinutes: $maxRecordingMinutes, refinementEnabled: $refinementEnabled)';
}


}

/// @nodoc
abstract mixin class $SettingsStateCopyWith<$Res>  {
  factory $SettingsStateCopyWith(SettingsState value, $Res Function(SettingsState) _then) = _$SettingsStateCopyWithImpl;
@useResult
$Res call({
 bool launchAtStartup, HotKey hotkey, bool isAccessibilityAuthorized, bool isMicrophoneAuthorized, bool isRecordingHotkey, bool soundEnabled, String startSound, String stopSound, int historyRetentionDays, int maxRecordingMinutes, bool refinementEnabled
});




}
/// @nodoc
class _$SettingsStateCopyWithImpl<$Res>
    implements $SettingsStateCopyWith<$Res> {
  _$SettingsStateCopyWithImpl(this._self, this._then);

  final SettingsState _self;
  final $Res Function(SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? launchAtStartup = null,Object? hotkey = null,Object? isAccessibilityAuthorized = null,Object? isMicrophoneAuthorized = null,Object? isRecordingHotkey = null,Object? soundEnabled = null,Object? startSound = null,Object? stopSound = null,Object? historyRetentionDays = null,Object? maxRecordingMinutes = null,Object? refinementEnabled = null,}) {
  return _then(_self.copyWith(
launchAtStartup: null == launchAtStartup ? _self.launchAtStartup : launchAtStartup // ignore: cast_nullable_to_non_nullable
as bool,hotkey: null == hotkey ? _self.hotkey : hotkey // ignore: cast_nullable_to_non_nullable
as HotKey,isAccessibilityAuthorized: null == isAccessibilityAuthorized ? _self.isAccessibilityAuthorized : isAccessibilityAuthorized // ignore: cast_nullable_to_non_nullable
as bool,isMicrophoneAuthorized: null == isMicrophoneAuthorized ? _self.isMicrophoneAuthorized : isMicrophoneAuthorized // ignore: cast_nullable_to_non_nullable
as bool,isRecordingHotkey: null == isRecordingHotkey ? _self.isRecordingHotkey : isRecordingHotkey // ignore: cast_nullable_to_non_nullable
as bool,soundEnabled: null == soundEnabled ? _self.soundEnabled : soundEnabled // ignore: cast_nullable_to_non_nullable
as bool,startSound: null == startSound ? _self.startSound : startSound // ignore: cast_nullable_to_non_nullable
as String,stopSound: null == stopSound ? _self.stopSound : stopSound // ignore: cast_nullable_to_non_nullable
as String,historyRetentionDays: null == historyRetentionDays ? _self.historyRetentionDays : historyRetentionDays // ignore: cast_nullable_to_non_nullable
as int,maxRecordingMinutes: null == maxRecordingMinutes ? _self.maxRecordingMinutes : maxRecordingMinutes // ignore: cast_nullable_to_non_nullable
as int,refinementEnabled: null == refinementEnabled ? _self.refinementEnabled : refinementEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SettingsState].
extension SettingsStatePatterns on SettingsState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettingsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettingsState value)  $default,){
final _that = this;
switch (_that) {
case _SettingsState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettingsState value)?  $default,){
final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool launchAtStartup,  HotKey hotkey,  bool isAccessibilityAuthorized,  bool isMicrophoneAuthorized,  bool isRecordingHotkey,  bool soundEnabled,  String startSound,  String stopSound,  int historyRetentionDays,  int maxRecordingMinutes,  bool refinementEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.launchAtStartup,_that.hotkey,_that.isAccessibilityAuthorized,_that.isMicrophoneAuthorized,_that.isRecordingHotkey,_that.soundEnabled,_that.startSound,_that.stopSound,_that.historyRetentionDays,_that.maxRecordingMinutes,_that.refinementEnabled);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool launchAtStartup,  HotKey hotkey,  bool isAccessibilityAuthorized,  bool isMicrophoneAuthorized,  bool isRecordingHotkey,  bool soundEnabled,  String startSound,  String stopSound,  int historyRetentionDays,  int maxRecordingMinutes,  bool refinementEnabled)  $default,) {final _that = this;
switch (_that) {
case _SettingsState():
return $default(_that.launchAtStartup,_that.hotkey,_that.isAccessibilityAuthorized,_that.isMicrophoneAuthorized,_that.isRecordingHotkey,_that.soundEnabled,_that.startSound,_that.stopSound,_that.historyRetentionDays,_that.maxRecordingMinutes,_that.refinementEnabled);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool launchAtStartup,  HotKey hotkey,  bool isAccessibilityAuthorized,  bool isMicrophoneAuthorized,  bool isRecordingHotkey,  bool soundEnabled,  String startSound,  String stopSound,  int historyRetentionDays,  int maxRecordingMinutes,  bool refinementEnabled)?  $default,) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.launchAtStartup,_that.hotkey,_that.isAccessibilityAuthorized,_that.isMicrophoneAuthorized,_that.isRecordingHotkey,_that.soundEnabled,_that.startSound,_that.stopSound,_that.historyRetentionDays,_that.maxRecordingMinutes,_that.refinementEnabled);case _:
  return null;

}
}

}

/// @nodoc


class _SettingsState implements SettingsState {
  const _SettingsState({this.launchAtStartup = false, required this.hotkey, this.isAccessibilityAuthorized = false, this.isMicrophoneAuthorized = false, this.isRecordingHotkey = false, this.soundEnabled = true, this.startSound = kDefaultStartSound, this.stopSound = kDefaultStopSound, this.historyRetentionDays = 7, this.maxRecordingMinutes = 1, this.refinementEnabled = false});
  

@override@JsonKey() final  bool launchAtStartup;
@override final  HotKey hotkey;
@override@JsonKey() final  bool isAccessibilityAuthorized;
@override@JsonKey() final  bool isMicrophoneAuthorized;
@override@JsonKey() final  bool isRecordingHotkey;
@override@JsonKey() final  bool soundEnabled;
@override@JsonKey() final  String startSound;
@override@JsonKey() final  String stopSound;
@override@JsonKey() final  int historyRetentionDays;
@override@JsonKey() final  int maxRecordingMinutes;
@override@JsonKey() final  bool refinementEnabled;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsStateCopyWith<_SettingsState> get copyWith => __$SettingsStateCopyWithImpl<_SettingsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingsState&&(identical(other.launchAtStartup, launchAtStartup) || other.launchAtStartup == launchAtStartup)&&(identical(other.hotkey, hotkey) || other.hotkey == hotkey)&&(identical(other.isAccessibilityAuthorized, isAccessibilityAuthorized) || other.isAccessibilityAuthorized == isAccessibilityAuthorized)&&(identical(other.isMicrophoneAuthorized, isMicrophoneAuthorized) || other.isMicrophoneAuthorized == isMicrophoneAuthorized)&&(identical(other.isRecordingHotkey, isRecordingHotkey) || other.isRecordingHotkey == isRecordingHotkey)&&(identical(other.soundEnabled, soundEnabled) || other.soundEnabled == soundEnabled)&&(identical(other.startSound, startSound) || other.startSound == startSound)&&(identical(other.stopSound, stopSound) || other.stopSound == stopSound)&&(identical(other.historyRetentionDays, historyRetentionDays) || other.historyRetentionDays == historyRetentionDays)&&(identical(other.maxRecordingMinutes, maxRecordingMinutes) || other.maxRecordingMinutes == maxRecordingMinutes)&&(identical(other.refinementEnabled, refinementEnabled) || other.refinementEnabled == refinementEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,launchAtStartup,hotkey,isAccessibilityAuthorized,isMicrophoneAuthorized,isRecordingHotkey,soundEnabled,startSound,stopSound,historyRetentionDays,maxRecordingMinutes,refinementEnabled);

@override
String toString() {
  return 'SettingsState(launchAtStartup: $launchAtStartup, hotkey: $hotkey, isAccessibilityAuthorized: $isAccessibilityAuthorized, isMicrophoneAuthorized: $isMicrophoneAuthorized, isRecordingHotkey: $isRecordingHotkey, soundEnabled: $soundEnabled, startSound: $startSound, stopSound: $stopSound, historyRetentionDays: $historyRetentionDays, maxRecordingMinutes: $maxRecordingMinutes, refinementEnabled: $refinementEnabled)';
}


}

/// @nodoc
abstract mixin class _$SettingsStateCopyWith<$Res> implements $SettingsStateCopyWith<$Res> {
  factory _$SettingsStateCopyWith(_SettingsState value, $Res Function(_SettingsState) _then) = __$SettingsStateCopyWithImpl;
@override @useResult
$Res call({
 bool launchAtStartup, HotKey hotkey, bool isAccessibilityAuthorized, bool isMicrophoneAuthorized, bool isRecordingHotkey, bool soundEnabled, String startSound, String stopSound, int historyRetentionDays, int maxRecordingMinutes, bool refinementEnabled
});




}
/// @nodoc
class __$SettingsStateCopyWithImpl<$Res>
    implements _$SettingsStateCopyWith<$Res> {
  __$SettingsStateCopyWithImpl(this._self, this._then);

  final _SettingsState _self;
  final $Res Function(_SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? launchAtStartup = null,Object? hotkey = null,Object? isAccessibilityAuthorized = null,Object? isMicrophoneAuthorized = null,Object? isRecordingHotkey = null,Object? soundEnabled = null,Object? startSound = null,Object? stopSound = null,Object? historyRetentionDays = null,Object? maxRecordingMinutes = null,Object? refinementEnabled = null,}) {
  return _then(_SettingsState(
launchAtStartup: null == launchAtStartup ? _self.launchAtStartup : launchAtStartup // ignore: cast_nullable_to_non_nullable
as bool,hotkey: null == hotkey ? _self.hotkey : hotkey // ignore: cast_nullable_to_non_nullable
as HotKey,isAccessibilityAuthorized: null == isAccessibilityAuthorized ? _self.isAccessibilityAuthorized : isAccessibilityAuthorized // ignore: cast_nullable_to_non_nullable
as bool,isMicrophoneAuthorized: null == isMicrophoneAuthorized ? _self.isMicrophoneAuthorized : isMicrophoneAuthorized // ignore: cast_nullable_to_non_nullable
as bool,isRecordingHotkey: null == isRecordingHotkey ? _self.isRecordingHotkey : isRecordingHotkey // ignore: cast_nullable_to_non_nullable
as bool,soundEnabled: null == soundEnabled ? _self.soundEnabled : soundEnabled // ignore: cast_nullable_to_non_nullable
as bool,startSound: null == startSound ? _self.startSound : startSound // ignore: cast_nullable_to_non_nullable
as String,stopSound: null == stopSound ? _self.stopSound : stopSound // ignore: cast_nullable_to_non_nullable
as String,historyRetentionDays: null == historyRetentionDays ? _self.historyRetentionDays : historyRetentionDays // ignore: cast_nullable_to_non_nullable
as int,maxRecordingMinutes: null == maxRecordingMinutes ? _self.maxRecordingMinutes : maxRecordingMinutes // ignore: cast_nullable_to_non_nullable
as int,refinementEnabled: null == refinementEnabled ? _self.refinementEnabled : refinementEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
