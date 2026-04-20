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

The folder `Unselected/` contains the implementation using the C2 architecture.

Versioning information:
```
Flutter 3.38.6 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 8b87286849 (3 months ago) • 2026-01-08 10:49:17 -0800
Engine • hash 6f3039bf7c3cb5306513c75092822d4d94716003 (revision 78fc3012e4) (3 months ago) • 2026-01-07 18:42:12.000Z
Tools • Dart 3.10.7 • DevTools 2.51.1
```

Please follow the instructions to set up Flutter at https://docs.flutter.dev/install/with-vs-code

TODO: Compilation instructions will be added shortly.

## Architectural Detail Comparison

TODO: This information will be added shortly.

