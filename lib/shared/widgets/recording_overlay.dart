import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zero_type/core/controllers/zero_type_controller.dart';
import 'package:zero_type/core/state/zero_type_state.dart';

/// On macOS the recording overlay is rendered as a native NSPanel (AppDelegate.swift).
/// On Windows this widget provides the Flutter-side equivalent inside the main window.
class RecordingOverlay extends ConsumerWidget {
  const RecordingOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!Platform.isWindows) return const SizedBox.shrink();

    final state = ref.watch(zeroTypeControllerProvider);
    if (!state.isActive) return const SizedBox.shrink();

    return _WindowsOverlay(state: state);
  }
}

// ── Windows overlay ─────────────────────────────────────────────────────────

class _WindowsOverlay extends ConsumerStatefulWidget {
  const _WindowsOverlay({required this.state});
  final ZeroTypeState state;

  @override
  ConsumerState<_WindowsOverlay> createState() => _WindowsOverlayState();
}

class _WindowsOverlayState extends ConsumerState<_WindowsOverlay> {
  bool _handleKey(KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      ref.read(zeroTypeControllerProvider.notifier).cancel();
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: _OverlayPill(
          state: widget.state,
          onCancel: () =>
              ref.read(zeroTypeControllerProvider.notifier).cancel(),
        ),
      ),
    );
  }
}

// ── Pill widget ──────────────────────────────────────────────────────────────

class _OverlayPill extends StatelessWidget {
  const _OverlayPill({required this.state, required this.onCancel});
  final ZeroTypeState state;
  final VoidCallback onCancel;

  Color get _dotColor => switch (state.status) {
        ZeroTypeStatus.recording => const Color(0xFF6C63FF),
        ZeroTypeStatus.cancelling => Colors.grey,
        ZeroTypeStatus.saving => const Color(0xFFFFAA00),
        ZeroTypeStatus.transcribing => const Color(0xFF63B3FF),
        ZeroTypeStatus.done => Colors.greenAccent,
        ZeroTypeStatus.error => Colors.redAccent,
        ZeroTypeStatus.idle => Colors.grey,
      };

  String get _label {
    if (state.status == ZeroTypeStatus.error) {
      final msg = state.errorMessage;
      return (msg == null || msg.isEmpty) ? '錯誤' : '錯誤：$msg';
    }
    return switch (state.status) {
          ZeroTypeStatus.recording => '錄音中',
          ZeroTypeStatus.cancelling => '取消中',
          ZeroTypeStatus.saving => '擷取中',
          ZeroTypeStatus.transcribing => '辨識中',
          ZeroTypeStatus.done => '已完成',
          ZeroTypeStatus.error => '錯誤',
          ZeroTypeStatus.idle => '',
        };
  }

  bool get _showWaveform =>
      state.status == ZeroTypeStatus.recording ||
      state.status == ZeroTypeStatus.saving;

  @override
  Widget build(BuildContext context) {
    final dotColor = _dotColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _PulsingDot(color: dotColor, active: _showWaveform),
          const SizedBox(width: 10),
          if (_showWaveform) ...[
            _WaveformBars(amplitude: state.amplitude, color: dotColor),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Text(
                _label,
                style: TextStyle(
                  color: dotColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (state.status == ZeroTypeStatus.saving ||
              state.status == ZeroTypeStatus.transcribing) ...[
            const SizedBox(width: 1),
            _AnimatedDots(color: dotColor),
          ],
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onCancel,
            child: Icon(
              Icons.close,
              color: dotColor.withValues(alpha: 0.7),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pulsing dot ──────────────────────────────────────────────────────────────

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color, required this.active});
  final Color color;
  final bool active;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.active) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_PulsingDot old) {
    super.didUpdateWidget(old);
    if (widget.active && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.active) {
      _ctrl.stop();
      _ctrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ── Animated dots ─────────────────────────────────────────────────────────────

class _AnimatedDots extends StatefulWidget {
  const _AnimatedDots({required this.color});
  final Color color;

  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final dotCount = (_ctrl.value * 3).floor() + 1;
        return Text(
          '.' * dotCount,
          style: TextStyle(
            color: widget.color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }
}

// ── Waveform bars ─────────────────────────────────────────────────────────────

class _WaveformBars extends StatelessWidget {
  const _WaveformBars({required this.amplitude, required this.color});
  final double amplitude;
  final Color color;

  static const _barCount = 5;
  static const _maxHeight = 20.0;
  static const _minHeight = 4.0;

  // Pre-computed sensitivity factors per bar (fixed seed → stable pattern)
  static final List<double> _factors = () {
    final rng = Random(42);
    return List.generate(_barCount, (_) => 0.4 + rng.nextDouble() * 0.6);
  }();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(_barCount, (i) {
        final h = _minHeight +
            (_maxHeight - _minHeight) *
                (amplitude * _factors[i]).clamp(0.0, 1.0);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            width: 3,
            height: h,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
