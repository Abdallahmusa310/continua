import 'package:continua/core/const/app_color.dart';
import 'package:flutter/material.dart';

class WelcmeSction extends StatelessWidget {
  const WelcmeSction({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello ',
            style: TextStyle(fontSize: 24, color: Appcolor.textcolor),
          ),
          SizedBox(height: 8),
          Text(
            'What do you want to learn today ?',
            style: TextStyle(fontSize: 16, color: Appcolor.secondtextcolor),
          ),
        ],
      ),
    );
  }
}
