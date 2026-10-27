import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';

class DropdownWithLabel extends StatelessWidget {
  final String labelText;
  final List<String> items;
  final String? hintText;
  final String? selectedValue;
  final ValueChanged<String?>? onChanged;
  final FormFieldValidator<String>? validator;

  const DropdownWithLabel({
    super.key,
    required this.labelText,
    required this.items,
    this.hintText,
    this.selectedValue,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: labelText,
                style: TextStyle(
                  color: context.staff.muted,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const TextSpan(
                text: '*',
                style: TextStyle(
                  color: Color(0xFFB22222),
                  fontSize: 14,
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 5.h),
        DropdownButtonFormField<String>(
          value: selectedValue,
          hint: Text(hintText ?? "Select School"),
          items: items.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0.r),
              borderSide: BorderSide(width: 0.5.w, color: context.staff.muted),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0.r),
              borderSide: BorderSide(width: 0.5.w, color: context.staff.muted),
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 10.h,
              horizontal: 10.w,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0.r),
              borderSide: BorderSide(width: 0.5.w, color: context.staff.muted),
            ),
          ),
        ),
      ],
    );
  }
}
