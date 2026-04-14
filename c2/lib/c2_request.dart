// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io' show Directory, Platform;

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'package:c2/c2_notification.dart';

typedef ProcessRequestNative = Void Function(Message request);
typedef ProcessRequest = void Function(Message request);

void sendRequest(String name, String data) {
  // Open the dynamic library
  var libraryPath = path.join(
    Directory.current.path,
    'platform',
    'libbackend.so',
  );
  if (Platform.isMacOS) {
    libraryPath = path.join(
      Directory.current.path,
      'platform',
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
  final dylib = DynamicLibrary.open(libraryPath);
  initNotificationCallback(dylib);

  final processRequest = dylib.lookupFunction<ProcessRequestNative, ProcessRequest>('process_request');
  final kRequestName = name.toNativeUtf8();
  final requestData = data.toNativeUtf8();

  final messagePtr = calloc<Message>();
  messagePtr.ref.name = kRequestName;
  messagePtr.ref.data = requestData;
  processRequest(messagePtr.ref);

  malloc.free(messagePtr.ref.name.cast());
  malloc.free(messagePtr.ref.data.cast());
  malloc.free(messagePtr);
}
