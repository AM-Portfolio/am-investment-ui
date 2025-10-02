import 'package:flutter/material.dart';

/// Import data options
enum ImportDataOption {
  excel('Upload Excel/CSV file', Icons.file_upload),
  broker('Connect broker account', Icons.link),
  manual('Manual entry', Icons.edit);

  const ImportDataOption(this.label, this.icon);
  final String label;
  final IconData icon;
}