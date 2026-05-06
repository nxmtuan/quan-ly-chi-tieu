String formatCurrency(num value) {
  final isNegative = value < 0;
  final rounded = value.abs().round().toString();
  final buffer = StringBuffer();

  for (var index = 0; index < rounded.length; index++) {
    final reverseIndex = rounded.length - index;
    buffer.write(rounded[index]);

    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write('.');
    }
  }

  return '${isNegative ? '-' : ''}${buffer.toString()} ₫';
}

String formatShortDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');

  return '$day/$month/${date.year}';
}

String formatMonthDay(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');

  return '$day/$month';
}
