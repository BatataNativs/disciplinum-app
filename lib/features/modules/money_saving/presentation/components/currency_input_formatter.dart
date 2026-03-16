import 'package:flutter/services.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final String currency;

  CurrencyInputFormatter({required this.currency});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    // Apenas números
    String cleaned = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return newValue.copyWith(text: '');

    double value = double.parse(cleaned) / 100;

    // Formatação baseada na moeda
    bool isLatin = currency == 'R\$' || currency == '€' || currency == '\$';

    String formatted;
    if (isLatin) {
      formatted = _formatWithSeparators(value,
          decimalSeparator: ',', thousandSeparator: '.');
    } else {
      formatted = _formatWithSeparators(value,
          decimalSeparator: '.', thousandSeparator: ',');
    }

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatWithSeparators(double value,
      {required String decimalSeparator, required String thousandSeparator}) {
    String fixed = value.toStringAsFixed(2);
    List<String> parts = fixed.split('.');
    String whole = parts[0];
    String decimal = parts[1];

    String result = '';
    int count = 0;
    for (int i = whole.length - 1; i >= 0; i--) {
      result = whole[i] + result;
      count++;
      if (count == 3 && i > 0) {
        result = thousandSeparator + result;
        count = 0;
      }
    }

    return result + decimalSeparator + decimal;
  }
}
