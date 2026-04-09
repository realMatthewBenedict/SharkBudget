# Shark Budget

Shark Budget is a JavaFX desktop budget tracker built in Java 21.

## Main Features
- Register and login
- Persistent local data storage (JSON file)
- Add income and expense transactions
- Transaction history with search and filters
- Dashboard summary with charts
- Monthly savings target
- CSV export

## Tech Stack
- Java 21
- JavaFX
- Maven
- Jackson (for JSON persistence)

## Data Storage
The app saves data locally in:
- Windows: `C:\Users\YourName\.sharkbudget\data.json`
- macOS/Linux: `~/.sharkbudget/data.json`

## Run with Maven
Open the project in IntelliJ IDEA and run:
- Maven goal: `javafx:run`

Or use the Maven tool window and run the `javafx:run` goal.
