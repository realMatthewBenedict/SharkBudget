FLUTTER_ROOT=$(dirname "$(dirname "$(which flutter)")")
DART_SDK_PATH="$FLUTTER_ROOT/bin/cache/dart-sdk"
clang -shared -fPIC \
    -mmacosx-version-min=10.15 \
    -I"$DART_SDK_PATH/include" \
    -o macos/Runner/Frameworks/libbackend.dylib \
    "$DART_SDK_PATH/include/dart_api_dl.c" \
    platform/*.c \
    -lsqlite3 && \
    clang-format -i platform/*.h platform/*.c
