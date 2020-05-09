import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final Function validator;
  final String initialValue;

  TextFieldWidget(
      {this.hint, this.controller, this.validator, this.initialValue});

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 300,
      child: TextFormField(
        initialValue: initialValue,
        validator: validator,
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          labelText: hint,
          hintText: hint,
        ),
        autofocus: false,
      ),
    );
  }
}
