import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

Future<void> pickLogFile(BuildContext context) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['txt'],
  );

  if (result == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File selection canceled.'),
        duration: Duration(seconds: 2),
      ),
    );
  } else {
    PlatformFile file = result.files.first;
    analyzeLogFile(file.path);
  }
}

Future<void> pickUserDataFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv', 'xls'],
  );

  if (result != null) {
    PlatformFile file = result.files.first;
    analyzeUserData(file.path);
  } else {}
}

void analyzeUserData(String? path) {}

void analyzeLogFile(String? filePath) async {
  var file = File(filePath!);
  List<String> lines = await file.readAsLines();

  Map<String, int> loginAttempts = {};
  List<String> suspiciousLogs = [];

  for (var line in lines) {
    var parts = line.split(',');
    var user = parts[1].split('@')[0];
    var outcome = parts.last;

    if (outcome.contains("Fail")) {
      loginAttempts[user] = (loginAttempts[user] ?? 0) + 1;
      if (loginAttempts[user]! > 5) {
        suspiciousLogs.add(line);
      }
    }

    if (user.contains('evil') ||
        !user.startsWith('C') ||
        user.contains('\$')) {
      suspiciousLogs.add(line);
    }
  }

  for (var log in suspiciousLogs) {
    print("Suspicious Log: $log");
  }
}
