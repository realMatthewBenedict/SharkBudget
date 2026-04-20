mergeInto(LibraryManager.library, {
  NotifyDartImpl: function(namePtr, dataPtr) {
    const name = UTF8ToString(namePtr);
    const data = UTF8ToString(dataPtr);
    dartHandleNotification(name, data);
  }
});
