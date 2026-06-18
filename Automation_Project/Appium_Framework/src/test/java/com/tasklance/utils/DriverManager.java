package com.tasklance.utils;

import io.appium.java_client.android.AndroidDriver;
import io.appium.java_client.android.options.UiAutomator2Options;
import java.net.MalformedURLException;
import java.net.URL;
import java.time.Duration;

public class DriverManager {
    private static AndroidDriver driver;

    public static AndroidDriver getDriver() {
        if (driver == null) {
            UiAutomator2Options options = new UiAutomator2Options()
                    .setDeviceName("Android Emulator")
                    .setAutomationName("UiAutomator2")
                    .setAppPackage("com.example.tasklance") // Needs verification from AndroidManifest.xml
                    .setAppActivity("com.example.tasklance.MainActivity")
                    .setNoReset(false)
                    .setFullReset(false)
                    .setNewCommandTimeout(Duration.ofSeconds(60));

            try {
                driver = new AndroidDriver(new URL("http://127.0.0.1:4723/"), options);
                driver.manage().timeouts().implicitlyWait(Duration.ofSeconds(10));
            } catch (MalformedURLException e) {
                e.printStackTrace();
            }
        }
        return driver;
    }

    public static void quitDriver() {
        if (driver != null) {
            driver.quit();
            driver = null;
        }
    }
}
