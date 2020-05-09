import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String header;
  final String date;

  Header({this.header, this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Flexible(
          child: Text(
            header,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),
          ),
        ),
        Flexible(child: Text(date)),
      ],
    );
  }
}
