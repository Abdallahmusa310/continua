import 'package:continua/core/const/app_color.dart';
import 'package:flutter/material.dart';

class CourcesHeader extends StatelessWidget {
  const CourcesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Courses',
        style: TextStyle(fontSize: 20, color: Appcolor.textcolor),
      ),
    );
  }
}
