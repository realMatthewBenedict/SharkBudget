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

Detailed Instruction on how to run the code:

1. Download the zip file and decompress
2. Open the intelij idea and open the file
3. This is a Maven project, so ensure to install dependencies
4. Make sure you selected the above JDK 21 and JavaFX SDK 
5. Open the Maven panel and expand the file:
    Plugins
      -> javafx
          -> javafx:run
6. Double click the javaFX and run the program.

notes: the chart is a redundant function becuese the dashboard already show the chart 

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

> ⚠️ **Warning:** For evaluation purposes, please compile for the native macOS platform on macOS. Due to a dependency issue, you should perform this in a directory with an absolute path containing no spaces. The functionality of other builds is not guaranteed.

Please follow the instructions to set up Flutter at https://docs.flutter.dev/install/with-vs-code (ensuring to restart VS Code after downloading the Flutter SDK).

You will also need the clang C compiler:
* Obtain `clang` on macOS with the Xcode command line tools (installed with `xcode-select --install`)
* Obtain `clang-cl` on Windows from MSVC in the installer at https://visualstudio.microsoft.com/visual-cpp-build-tools/ on Windows.

In the Unselected directory, run `dart pub get` and then `dart run sqflite_common_ffi_web:setup` to get dependencies.

The platform you are compiling for may need additional dependencies. For instance:

* The web implementation requires Emscripten from https://emscripten.org/docs/getting_started/downloads.html
* The native macOS implementation requires Xcode from https://developer.apple.com/xcode/
* The native Android implementation requires the Android SDK found in Android Studio from https://developer.android.com/studio

To do this, run `platform/compile/macos.sh` then `flutter run -d macos`

Steps for other platforms are similar.

## Architectural Detail Comparison

## Architecture Comparison: C2 vs. Layered

> ⚠️ **Note:** In our project, we implemented the layered architecture in a homogenous way, with all layers being implemented in Java, while our C2 implementation was heterogenous, with a frontend implemented in a different programming language than the backend (specifically Dart and C, respectively, although other languages may be used internally by Flutter). This creates an architectural comparison on an uneven footing, since we are comparing a heterogenous implementation and homogenous implementation at the same time as two different architecture styles.
>
> Despite the constraints, including time and the fact our group only had two members, it would have likely been a more meaningful project with better resulting analysis to use the same set of languages for both implementations, in order to solely examine the impact of architecture style, rather than also having the confounding factor of heterogeneity. For instance, while we could argue that layered architectural style is better because it only needed 13 classes versus 37 on the class diagram, while still achieving approximately the same functionality, there is some nuance with a different choice of persistent data store (JSON vs. SQLite), and of course the necessity of message passing between heterogeneous layers, which also would have been necessary if the layered architecture had been heterogeneous.
>
> In addition, C of course does not have classes, with the closest approximation of structs usually not containing methods. As a result, the class diagram could not be implemented literally on the C side. As a result, in the unselected implementation, to accommodate more platforms, classes particularly pertaining to C2Request's Dart implementation were adjusted since the presentation.

For the **Shark Budget** project, both **C2** and **Layered Architecture** were considered as candidate architectural styles.
Each style has its own strengths, but they support the system in different ways.
Shark Budget is a personal budget tracking system whose main workflow is relatively direct:
the user enters transaction data, the system processes it, calculates summaries, and stores or retrieves records for display.
Because of this workflow, the architecture needs to be clear, maintainable, and easy to implement.

The **C2 architectural style**, as implemented, provides strong separation between components through message-based communication.
This makes it a good choice for systems that require loose coupling, independent component interaction, or more distributed and event-driven behavior.
This also makes it well-suited to support cases where different parts of the system are implemented in different languages or platforms.
However, for Shark Budget, C2 introduces additional complexity that is not strictly necessary.
In our case, we needed to pass communication through message-based request and notification handlers,
which adds design overhead, increases implementation effort, and may reduce efficiency because of serialization and deserialization of data.
This does provide decent support for an observer pattern if multiple components were to respond to the same notification, but this is not well taken advantage of in this implementation.
This extra flexibility is valuable in larger or more distributed systems, or in deployment as a thin client at scale, but it is less beneficial for a standalone budget tracker.

The **Layered architectural style** is more suitable for this project because it matches the system structure naturally. The presentation layer handles user interaction and screen display, the business logic layer processes transactions and calculates summaries, and the data access layer manages persistence. This separation of responsibilities makes the system easier to understand, develop, test, and maintain. It also supports future extension, since new features can usually be added by modifying one layer without heavily affecting the others.

In summary, **C2 is more flexible but also more complex**, while **Layered Architecture is simpler and more practical** for Shark Budget. Since this project is a small-to-medium desktop budget application rather than a highly distributed system, the layered approach provides the best balance of simplicity, modularity, maintainability, and development effort. 

