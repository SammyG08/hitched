import 'package:flutter/material.dart';

class FormJourneyImage extends StatelessWidget {
  const FormJourneyImage({this.height = 112, super.key});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(
        'assets/images/planning_form_header.png',
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }
}
