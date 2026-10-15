# Issue 01: Scaffold Flutter macOS Project and Core Dependencies

Type: task
Status: resolved
Blocked by:

## Question

How should the Flutter macOS desktop project and directory structure be initialized with required dependencies (`flutter_riverpod`, `http`, `shared_preferences`, `path_provider`, etc.) so that it compiles and launches cleanly on macOS?

## Answer

Created the Flutter macOS desktop application, added all primary dependencies (`flutter_riverpod`, `http`, `shared_preferences`, `path_provider`, `file_picker`, `csv`), enabled network client sandbox entitlements (`com.apple.security.network.client`) in both Debug and Release profiles, and verified end-to-end compilation with `flutter build macos --debug`.
