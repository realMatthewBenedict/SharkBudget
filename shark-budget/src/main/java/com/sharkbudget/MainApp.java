package com.sharkbudget;

import com.sharkbudget.ui.AppContext;
import com.sharkbudget.ui.DashboardView;
import com.sharkbudget.ui.LoginView;
import javafx.application.Application;
import javafx.scene.Scene;
import javafx.stage.Stage;

public class MainApp extends Application {
    private Stage primaryStage;
    private AppContext appContext;

    @Override
    public void start(Stage stage) {
        this.primaryStage = stage;
        this.appContext = new AppContext();

        primaryStage.setTitle("Shark Budget");
        showLoginView();
        primaryStage.show();
    }

    public void showLoginView() {
        LoginView loginView = new LoginView(appContext, this);
        Scene scene = new Scene(loginView.getView(), 1100, 720);
        primaryStage.setScene(scene);
    }

    public void showDashboardView(String username) {
        DashboardView dashboardView = new DashboardView(appContext, this, username);
        Scene scene = new Scene(dashboardView.getView(), 1200, 760);
        primaryStage.setScene(scene);
    }

    public static void main(String[] args) {
        launch(args);
    }
}
