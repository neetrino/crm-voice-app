String formatClockDuration(int seconds) {
  final safeSeconds = seconds < 0 ? 0 : seconds;
  final minutes = (safeSeconds ~/ 60).toString().padLeft(2, '0');
  final rest = (safeSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$rest';
}

String formatArmenianDateTime(DateTime? value) {
  if (value == null) return '-';
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final year = local.year.toString();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day.$month.$year $hour:$minute';
}
