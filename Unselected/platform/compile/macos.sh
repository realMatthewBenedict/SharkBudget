DART_SDK=/Users/matthewbenedict/Documents/git/flutter/bin/cache/dart-sdk
clang -shared -fPIC \
    -mmacosx-version-min=10.15 \
    -I"$DART_SDK/include" \
    -o macos/Runner/Frameworks/libbackend.dylib \
    "$DART_SDK/include/dart_api_dl.c" \
    platform/*.c \
    -lsqlite3 && \
    clang-format -i platform/*.h platform/*.c
