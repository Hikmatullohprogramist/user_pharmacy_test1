import 'package:flutter/services.dart';

class PhoneNumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final int newTextLength = newValue.text.length;
    int selectionIndex = newValue.selection.end;
    int usedSubstringIndex = 0;
    final StringBuffer newText = new StringBuffer();
    if (newTextLength >= 1) {
      newText.write(newValue.text.substring(0, usedSubstringIndex = 0) + '+');
      if (newValue.selection.end >= 0) selectionIndex++;
    }
    if (newTextLength >= 4) {
      newText.write(newValue.text.substring(0, usedSubstringIndex = 3) + ' ');
      if (newValue.selection.end >= 3) selectionIndex++;
    }
    if (newTextLength >= 6) {
      newText.write(newValue.text.substring(3, usedSubstringIndex = 5) + ' ');
      if (newValue.selection.end >= 5) selectionIndex++;
    }
    if (newTextLength >= 9) {
      newText.write(newValue.text.substring(5, usedSubstringIndex = 8) + ' ');
      if (newValue.selection.end >= 8) selectionIndex++;
    }
    if (newTextLength >= 11) {
      newText.write(newValue.text.substring(8, usedSubstringIndex = 10) + ' ');
      if (newValue.selection.end >= 10) selectionIndex++;
    }

    if (newTextLength >= usedSubstringIndex)
      newText.write(newValue.text.substring(usedSubstringIndex));
    return new TextEditingValue(
      text: newText.toString(),
      selection: new TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
