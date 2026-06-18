package com.tasklance.utils;

import com.aventstack.extentreports.ExtentReports;
import com.aventstack.extentreports.reporter.ExtentSparkReporter;
import com.aventstack.extentreports.reporter.configuration.Theme;

public class ExtentReportManager {
    private static ExtentReports extent;

    public static ExtentReports getInstance() {
        if (extent == null) {
            String reportPath = System.getProperty("user.dir") + "/Reports/Extent_Report/ExtentReport.html";
            ExtentSparkReporter sparkReporter = new ExtentSparkReporter(reportPath);
            sparkReporter.config().setTheme(Theme.DARK);
            sparkReporter.config().setDocumentTitle("TaskLance Automation Report");
            sparkReporter.config().setReportName("TaskLance E2E Test Execution");

            extent = new ExtentReports();
            extent.attachReporter(sparkReporter);
            extent.setSystemInfo("Platform", "Android");
            extent.setSystemInfo("App", "TaskLance");
            extent.setSystemInfo("QA Engineer", "Elite Senior QA");
        }
        return extent;
    }
}
