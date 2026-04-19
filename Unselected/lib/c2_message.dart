import 'dart:ffi';
import 'dart:io' show Directory, Platform;

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;

final class Message extends Struct {
  external Pointer<Utf8> name;
  external Pointer<Utf8> data;

  static DynamicLibrary getDylib() {
    // Open the dynamic library
    var libraryPath = path.join(
      Directory.current.path,
      'platform',
      'libbackend.so',
    );
    if (Platform.isMacOS) {
      libraryPath = path.join(
        path.dirname(Platform.resolvedExecutable),
        '..',
        'Frameworks',
        'libbackend.dylib',
      );
    }
    if (Platform.isWindows) {
      libraryPath = path.join(
        Directory.current.path,
        'platform',
        'Debug',
        'backend.dll',
      );
    }
    return DynamicLibrary.open(libraryPath);
  }
}
