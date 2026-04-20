export 'package:c2/c2_request_abstract.dart' // Stub implementation
    if (dart.library.ffi) 'package:c2/c2_request_ffi.dart' // dart:ffi implementation
    if (dart.library.html) 'package:c2/c2_request_web.dart'; // dart:js implementation
