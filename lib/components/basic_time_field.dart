import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BasicTimeField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final Function validator;

  BasicTimeField({this.validator, this.hint, this.controller});

  final format = DateFormat("h:mm a");
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: DateTimeField(
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
        onShowPicker: (context, currentValue) async {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
          );
          return DateTimeField.convert(time);
        },
      ),
    );
  }
}
