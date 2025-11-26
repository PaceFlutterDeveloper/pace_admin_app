// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class FormFieldWidget extends StatelessWidget {
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool obSecureText;
  final Widget? suffix;
  final String? hintText;
  final String? label;
  final FocusNode? focusNode;
  final IconData? data;
  final Function(String)? onChanged;
  final String? initialValue;
  const FormFieldWidget({
    Key? key,
    this.validator,
    this.controller,
    this.obSecureText = false,
    this.suffix,
    this.hintText,
    this.label,
    this.focusNode,
    this.data,
    this.onChanged,
    this.initialValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      focusNode: focusNode,
      validator: validator,
      obscureText: obSecureText,
      controller: controller,
      decoration: InputDecoration(
          suffixIcon: suffix,
          isDense: true,
          filled: true,
          border: UnderlineInputBorder(borderRadius: BorderRadius.circular(5)),
          prefixIcon: data == null ? null : Icon(data),
          hintText: hintText,
          label: label == null ? null : Text(label!)),
    );
  }
}
