package com.sharkbudget.ui;

import com.sharkbudget.MainApp;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Parent;
import javafx.scene.control.*;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.scene.text.Font;

public class LoginView {
    private final AppContext appContext;
    private final MainApp mainApp;
    private final BorderPane root;

    public LoginView(AppContext appContext, MainApp mainApp) {
        this.appContext = appContext;
        this.mainApp = mainApp;
        this.root = buildView();
    }

    public Parent getView() {
        return root;
    }

    private BorderPane buildView() {
        BorderPane pane = new BorderPane();
        pane.setStyle("-fx-background-color: linear-gradient(to bottom right, #f4f8ff, #ffffff);");

        VBox card = new VBox(12);
        card.setAlignment(Pos.CENTER_LEFT);
        card.setPadding(new Insets(30));
        card.setMaxWidth(420);
        card.setStyle("-fx-background-color: white; -fx-background-radius: 12; -fx-border-radius: 12;"
                + "-fx-border-color: #d9e2f2; -fx-border-width: 1;");

        Label title = new Label("Shark Budget");
        title.setFont(Font.font(28));

        Label subtitle = new Label("Login or create a new account to manage your budget.");
        subtitle.setStyle("-fx-text-fill: #5c6b7a;");

        TextField usernameField = new TextField();
        usernameField.setPromptText("Username");

        PasswordField passwordField = new PasswordField();
        passwordField.setPromptText("Password");

        Label messageLabel = new Label();
        messageLabel.setWrapText(true);

        Button loginButton = new Button("Login");
        loginButton.setPrefWidth(150);

        Button registerButton = new Button("Register");
        registerButton.setPrefWidth(150);

        loginButton.setOnAction(event -> {
            try {
                boolean success = appContext.getAuthService().login(usernameField.getText(), passwordField.getText());
                if (success) {
                    messageLabel.setText("");
                    mainApp.showDashboardView(usernameField.getText().trim());
                } else {
                    messageLabel.setText("Invalid username or password.");
                    messageLabel.setStyle("-fx-text-fill: #d62828;");
                }
            } catch (Exception e) {
                messageLabel.setText(e.getMessage());
                messageLabel.setStyle("-fx-text-fill: #d62828;");
            }
        });

        registerButton.setOnAction(event -> {
            try {
                boolean created = appContext.getAuthService().register(usernameField.getText(), passwordField.getText());
                if (created) {
                    messageLabel.setText("Account created successfully. You can log in now.");
                    messageLabel.setStyle("-fx-text-fill: #2a9d8f;");
                } else {
                    messageLabel.setText("That username already exists.");
                    messageLabel.setStyle("-fx-text-fill: #d62828;");
                }
            } catch (Exception e) {
                messageLabel.setText(e.getMessage());
                messageLabel.setStyle("-fx-text-fill: #d62828;");
            }
        });

        HBox buttonRow = new HBox(10, loginButton, registerButton);
        buttonRow.setAlignment(Pos.CENTER_LEFT);

        card.getChildren().addAll(title, subtitle,
                new Label("Username"), usernameField,
                new Label("Password"), passwordField,
                buttonRow, messageLabel);

        pane.setCenter(card);
        BorderPane.setAlignment(card, Pos.CENTER);
        return pane;
    }
}
