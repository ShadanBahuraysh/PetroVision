// Flutter Web implementation
// Uses dart:html to create a temporary anchor element and click it,
// which triggers the browser's native "Save As" dialog.
// This is the standard web download pattern for Flutter Web.

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<void> saveFileToDevice(List<int> bytes, String fileName) async {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..style.display = 'none';

  html.document.body!.append(anchor);
  anchor.click();
  anchor.remove();

  // Small delay before revoking so the browser has time to start the download
  await Future.delayed(const Duration(milliseconds: 300));
  html.Url.revokeObjectUrl(url);
}
