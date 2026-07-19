import 'package:continua/core/const/app_color.dart';
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Continua',
            style: TextStyle(fontSize: 24, color: Appcolor.primarycolor),
          ),
          SizedBox(
            width: 50,
            height: 50,
            child: Card(
              elevation: 3,
              color: Appcolor.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),

              child: Icon(Icons.person, color: Appcolor.primarycolor, size: 35),
            ),
          ),
        ],
      ),
    );
  }
}
