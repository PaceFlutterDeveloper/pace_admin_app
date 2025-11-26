// lib/core/utils/status_color.dart
import 'package:flutter/material.dart';

/// A simple map from your status‐option color keys to actual [Color]s.
const Map<String, Color> _statusColorMap = {
  'warning': Colors.orange,
  'info': Colors.blue,
  'danger': Colors.red,
  'primary': Colors.purple,
  'success': Colors.green,
  'dark': Colors.grey,
};

/// Returns the color for [key], or a neutral grey if unknown.
Color statusColorFromKey(String key) {
  return _statusColorMap[key.toLowerCase()] ?? Colors.grey.shade200;
}
