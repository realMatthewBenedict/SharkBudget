package com.sharkbudget.dao;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.sharkbudget.model.AppData;
import com.sharkbudget.util.DataFileUtil;

import java.nio.file.Files;
import java.nio.file.Path;

public class JsonDataStore implements DataStore {
    private final ObjectMapper objectMapper;
    private final Path dataFilePath;

    public JsonDataStore() {
        this.objectMapper = new ObjectMapper();
        this.objectMapper.registerModule(new JavaTimeModule());
        this.objectMapper.enable(SerializationFeature.INDENT_OUTPUT);
        this.dataFilePath = DataFileUtil.getDataFilePath();
    }

    @Override
    public AppData loadData() {
        try {
            if (!Files.exists(dataFilePath) || Files.size(dataFilePath) == 0) {
                AppData data = new AppData();
                saveData(data);
                return data;
            }
            return objectMapper.readValue(dataFilePath.toFile(), AppData.class);
        } catch (Exception e) {
            throw new RuntimeException("Could not load data from file.", e);
        }
    }

    @Override
    public void saveData(AppData data) {
        try {
            objectMapper.writeValue(dataFilePath.toFile(), data);
        } catch (Exception e) {
            throw new RuntimeException("Could not save data to file.", e);
        }
    }
}
