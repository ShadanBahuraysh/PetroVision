// ============================================================
// PetroVision Download Helper
// ============================================================
// Conditionally imports the web or native implementation.
// - On Flutter Web  → uses dart:html anchor trick (browser save dialog)
// - On Windows/Mac/Linux/Mobile → uses dart:io File write to Downloads
//
// Customer-side code never touches this file.
// ============================================================

export 'download_helper_stub.dart'
    if (dart.library.html) 'download_helper_web.dart'
    if (dart.library.io) 'download_helper_native.dart';
