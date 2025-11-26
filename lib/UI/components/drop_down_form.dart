import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DropDownForm extends StatelessWidget {
  const DropDownForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: FormBuilderDropdown(
          decoration: InputDecoration(
            isDense: true,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0.r),
              borderSide: BorderSide(
                color: Colors.green, // Customize this as per your need
                width: 0.5.w,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0.r),
              borderSide: BorderSide(
                color: Colors.green, // Customize this as per your need
                width: 0.5.w,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0.r),
              borderSide: BorderSide(
                color: Colors.green, // Customize this as per your need
                width: 0.5.w,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0.r),
              borderSide: BorderSide(
                color: Colors.green, // Customize this as per your need
                width: 0.5.w,
              ),
            ),
          ),
          name: 'dropdown',
          isExpanded: true,
          items: [
            "Normal",
            "Urgent",
            "Emergency",
          ].map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option),
            );
          }).toList()),
    );
  }
}
