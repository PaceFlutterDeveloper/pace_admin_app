import 'package:admin_app/UI/components/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FormFeildWithLabel extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatter;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final Widget? icon;
  const FormFeildWithLabel({
    super.key,
    required this.labelText,
    this.hintText,
    this.maxLines,
    this.inputFormatter,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.icon,
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
                  color: const Color(0xFF4F4F4F),
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
        CustomFormField(
          icon: icon,
          obscureText: obscureText,
          controller: controller,
          validator: validator,
        ),
      ],
    );
  }
}
