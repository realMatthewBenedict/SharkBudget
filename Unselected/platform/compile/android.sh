FLUTTER_ROOT=$(dirname "$(dirname "$(which flutter)")")
DART_SDK_PATH="$FLUTTER_ROOT/bin/cache/dart-sdk"
ANDROID_SDK_PATH=$(grep "^sdk.dir" android/local.properties | cut -d'=' -f2)
NDK_ROOT=$(ls -d "$ANDROID_SDK_PATH/ndk/"* | head -n1)
LLVM_PREBUILT="$NDK_ROOT/toolchains/llvm/prebuilt"
HOST_TAG=$(ls -1 "$LLVM_PREBUILT" | head -n1)
LLVM_BIN="$LLVM_PREBUILT/$HOST_TAG/bin"
CC="$LLVM_BIN/aarch64-linux-android21-clang"
$CC -shared -fPIC \
    -I"$DART_SDK_PATH/include" \
    -o android/app/src/main/jniLibs/arm64-v8a/libbackend.so \
    "$DART_SDK_PATH/include/dart_api_dl.c" \
    platform/*.c platform/third_party/*.c && \
    clang-format -i platform/*.h platform/*.c
