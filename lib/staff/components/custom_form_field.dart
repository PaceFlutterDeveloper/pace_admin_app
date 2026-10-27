import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';

class CustomFormField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatter;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final Widget? icon;

  const CustomFormField({
    super.key,
    this.labelText,
    this.maxLines = 1,
    this.hintText,
    this.controller,
    this.inputFormatter,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.icon,
  });

  @override
  State<CustomFormField> createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: widget.maxLines,
      inputFormatters: widget.inputFormatter,
      controller: widget.controller,
      obscureText: _obscure,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      decoration: InputDecoration(
        prefixIcon: widget.icon,
        labelStyle: TextStyle(
          color: context.staff.muted,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        hintStyle: TextStyle(
          color: context.staff.muted,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        isDense: true,
        labelText: widget.labelText,
        hintText: widget.hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0.r),
          borderSide: BorderSide(width: 0.5.w, color: context.staff.muted),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0.r),
          borderSide: BorderSide(width: 0.5.w, color: context.staff.muted),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0.r),
          borderSide: BorderSide(color: context.staff.muted, width: 0.5.w),
        ),
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  color: _obscure
                      ? const Color(0xFF9B8AFB)
                      : const Color(0xFF7A5AF8),
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  size: 20.sp,
                ),
                onPressed: () {
                  setState(() {
                    _obscure = !_obscure;
                  });
                },
              )
            : null,
      ),
    );
  }
}
