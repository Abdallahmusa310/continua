import 'package:continua/core/const/app_color.dart';
import 'package:flutter/material.dart';

class SearchTextfield extends StatelessWidget {
  const SearchTextfield({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search courses...',
            hintStyle: TextStyle(color: Appcolor.secondtextcolor, fontSize: 16),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Appcolor.secondtextcolor,
              size: 26,
            ),
            suffixIcon: Container(
              margin: const EdgeInsets.all(10),
              width: 40,
              decoration: BoxDecoration(
                color: Appcolor.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: Appcolor.secondtextcolor,
                size: 22,
              ),
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ),
    );
  }
}
