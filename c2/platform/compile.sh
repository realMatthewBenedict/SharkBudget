DART_SDK=/Users/matthewbenedict/Documents/git/flutter/bin/cache/dart-sdk
clang -shared -fPIC \
    -I"$DART_SDK/include" \
    -o platform/libbackend.dylib \
    platform/*.c \
    -lsqlite3
