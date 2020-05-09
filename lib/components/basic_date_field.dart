import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BasicDateField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final Function validator;

  BasicDateField({this.validator, this.hint, this.controller});

  final format = DateFormat("MMMM d, yyyy");
  @override
  Widget build(BuildContext context) {
    return DateTimeField(
      controller: controller,
      validator: validator,
      format: format,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        labelText: hint,
        hintText: hint,
      ),
      onShowPicker: (context, currentValue) {
        return showDatePicker(
            context: context,
            firstDate: DateTime(2020),
            initialDate: currentValue ?? DateTime.now(),
            lastDate: DateTime(2050));
      },
    );
  }
}
