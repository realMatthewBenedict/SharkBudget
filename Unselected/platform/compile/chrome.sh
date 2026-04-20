FLUTTER_ROOT=$(dirname "$(dirname "$(which flutter)")")
DART_SDK_PATH="$FLUTTER_ROOT/bin/cache/dart-sdk"
emcc -DDART_WEB \
  -O3 \
  -s WASM=1 \
  -s EXPORTED_FUNCTIONS='["_send_request", "_send_notification"]' \
  -s EXPORTED_RUNTIME_METHODS='["ccall", "cwrap"]' \
  -I"$DART_SDK/include" \
  --js-library "web/notification_bridge.js" \
  platform/*.c platform/third_party/*.c \
  -o web/libbackend.js && \
  clang-format -i platform/*.h platform/*.c