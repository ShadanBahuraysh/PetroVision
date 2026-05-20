// Native (Windows / macOS / Linux / Mobile) implementation
// Writes bytes directly to the user's Downloads folder.
// On Windows: uses USERPROFILE env var  →  C:\Users\Name\Downloads\
// On macOS/Linux: uses HOME env var     →  /Users/Name/Downloads/

import 'dart:io';
import 'dart:typed_data';

Future<void> saveFileToDevice(List<int> bytes, String fileName) async {
  String downloadsPath;

  if (Platform.isWindows) {
    final userProfile = Platform.environment['USERPROFILE'] ?? '';
    downloadsPath = userProfile.isNotEmpty
        ? '$userProfile\\Downloads'
        : Directory.current.path;
  } else {
    // macOS, Linux, or mobile fallback
    final home = Platform.environment['HOME'] ?? '';
    downloadsPath = home.isNotEmpty
        ? '$home/Downloads'
        : Directory.current.path;
  }

  final filePath = Platform.isWindows
      ? '$downloadsPath\\$fileName'
      : '$downloadsPath/$fileName';

  final file = File(filePath);
  await file.writeAsBytes(Uint8List.fromList(bytes), flush: true);
}
