package com.sharkbudget.util;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public class DataFileUtil {
    private static final String FOLDER_NAME = ".sharkbudget";
    private static final String FILE_NAME = "data.json";

    public static Path getDataFilePath() {
        String userHome = System.getProperty("user.home");
        Path folderPath = Paths.get(userHome, FOLDER_NAME);
        Path filePath = folderPath.resolve(FILE_NAME);

        try {
            if (!Files.exists(folderPath)) {
                Files.createDirectories(folderPath);
            }
        } catch (Exception e) {
            throw new RuntimeException("Could not create data folder.", e);
        }

        return filePath;
    }
}
