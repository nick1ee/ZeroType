import 'dart:io';

/// Lightweight append-only logger.
///
/// Writes to `%TEMP%\zero_type.log` on Windows / `/tmp/zero_type.log` on
/// macOS-Linux. Lines are timestamped. Mirrors to stdout via `print` so they
/// also show up when launched from a terminal (`flutter run -d windows`).
///
/// Rotates by size: when the file exceeds [_maxBytes], it is renamed to
/// `<name>.1` (overwriting any existing rotation) and a fresh file is started.
class AppLogger {
  AppLogger._();

  static const int _maxBytes = 1 * 1024 * 1024; // 1 MiB

  static File? _file;

  static File _resolveFile() {
    final dir = Directory.systemTemp.path;
    return File('$dir${Platform.pathSeparator}zero_type.log');
  }

  static void _ensureRotated(File f) {
    try {
      if (f.existsSync() && f.lengthSync() > _maxBytes) {
        final rotated = File('${f.path}.1');
        if (rotated.existsSync()) rotated.deleteSync();
        f.renameSync(rotated.path);
      }
    } catch (_) {
      // Rotation failures should not break the app.
    }
  }

  static void log(String tag, String message, {Object? error, StackTrace? st}) {
    final ts = DateTime.now().toIso8601String();
    final base = '[$ts] [$tag] $message';
    final full =
        error == null ? base : '$base\n  error: $error${st == null ? '' : '\n$st'}';

    // Always echo to stdout so a `flutter run -d windows` terminal sees it.
    // ignore: avoid_print
    print(full);

    try {
      final f = _file ??= _resolveFile();
      _ensureRotated(f);
      f.writeAsStringSync('$full\n', mode: FileMode.append, flush: false);
    } catch (_) {
      // If we can't write to disk we still have the print above.
    }
  }

  static String get logPath => _resolveFile().path;
}
