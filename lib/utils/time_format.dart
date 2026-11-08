/// Formats a duration in seconds as mm:ss.
String formatSeconds(int seconds) {
  final totalSeconds = seconds.clamp(0, 1 << 30);
  final minutes = totalSeconds ~/ 60;
  final remainingSeconds = totalSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
}
