Module.onRuntimeInitialized = function() {
  window._cSendRequest = Module.cwrap(
    "send_request",        // C function name
    null,                  // void return
    ["string", "string"]   // JS string → C char*
  );

  window.jsSendRequest = function(name, data) {
    window._cSendRequest(name, data);
  };
};
