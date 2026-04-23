This repository contains the implementations of SharkBudget.

## Layered Architecture

The folder `Selected/` contains the implementation using the layered architecture.

The selected implementation of Shark Budget is a JavaFX desktop budget tracker built in Java 21.

### Main Features
- Register and login
- Persistent local data storage (JSON file)
- Add income and expense transactions
- Transaction history with search and filters
- Dashboard summary with charts
- Monthly savings target
- CSV export

### Tech Stack
- Java 21
- JavaFX
- Maven
- Jackson (for JSON persistence)

### Data Storage
The app saves data locally in:
- Windows: `C:\Users\YourName\.sharkbudget\data.json`
- macOS/Linux: `~/.sharkbudget/data.json`

### Run with Maven
Please download IntelliJ IDEA from https://www.jetbrains.com/idea/download/.

Ensure you have a Java 21 JDK or newer and compatible JavaFX SDK installed.
One way to do this is installing the Liberica 21 LTS JDK from https://bell-sw.com/pages/downloads/#jdk-21-lts

For macOS users, installing the above JDK can be done automatically via Homebrew:
```
brew tap bell-sw/liberica
brew install --cask liberica-jdk21-full
```

Open the project in IntelliJ IDEA and run:
- Maven goal: `javafx:run`

Or use the Maven tool window and run the `javafx:run` goal.

## C2 Architecture

The folder `Unselected/` contains the implementation using the C2 architecture, built with Flutter for the frontend, C for the backend, and SQLite libraries for database operations.

Versioning information on my system (obtained via `flutter --version`):
```
Flutter 3.38.6 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 8b87286849 (4 months ago) • 2026-01-08 10:49:17 -0800
Engine • hash 6f3039bf7c3cb5306513c75092822d4d94716003 (revision 78fc3012e4) (3 months ago) • 2026-01-07 18:42:12.000Z
Tools • Dart 3.10.7 • DevTools 2.51.1
```

Please follow the instructions to set up Flutter at https://docs.flutter.dev/install/with-vs-code (ensuring to restart VS Code after downloading the Flutter SDK).

You will also need the clang C compiler:
* Obtain `clang` on macOS with the Xcode command line tools (installed with `xcode-select --install`)
* Obtain `clang-cl` on Windows from MSVC in the installer at https://visualstudio.microsoft.com/visual-cpp-build-tools/ on Windows.

In the Unselected directory, run `dart pub get` and then `dart run sqflite_common_ffi_web:setup` to get dependencies.

The platform you are compiling for may need additional dependencies. For instance:

* The web implementation requires Emscripten from https://emscripten.org/docs/getting_started/downloads.html
* The native macOS implementation requires Xcode from https://developer.apple.com/xcode/
* The native Android implementation requires the Android SDK found in Android Studio from https://developer.android.com/studio

**Warning:** Compiling the native macOS platform on macOS is recommended. The functionality of other builds is not guaranteed.

To do this, run `platform/compile/macos.sh` then `flutter run -d macos`

Steps for other platforms are similar.

## Architectural Detail Comparison

TODO: This information will be added shortly.

