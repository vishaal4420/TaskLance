import pytest
import pandas as pd
import os
from appium import webdriver
from appium.options.android import UiAutomator2Options

# Global list to store test results
test_results = []

@pytest.hookimpl(tryfirst=True, hookwrapper=True)
def pytest_runtest_makereport(item, call):
    # Execute all other hooks to obtain the report object
    outcome = yield
    report = outcome.get_result()
    
    # We only care about the actual test call, not setup/teardown
    if report.when == "call":
        # Determine Category based on pytest markers
        category = "Uncategorized"
        if item.get_closest_marker("ui_ux"):
            category = "UI_UX"
        elif item.get_closest_marker("functional"):
            category = "Functional"
        elif item.get_closest_marker("validation"):
            category = "Validation"
            
        # Append result to global list
        test_results.append({
            "Test Name": item.name,
            "Category": category,
            "Status": report.outcome.upper(),
            "Duration (s)": round(report.duration, 2),
            "Error Details": str(report.longrepr) if report.failed else "N/A"
        })

def pytest_terminal_summary(terminalreporter, exitstatus, config):
    """
    Called after all tests finish. Generates the multi-tab Excel report.
    """
    reports_dir = os.path.join(os.path.dirname(__file__), 'reports')
    os.makedirs(reports_dir, exist_ok=True)
    report_path = os.path.join(reports_dir, 'Deployable_Status_Report.xlsx')
    
    df = pd.DataFrame(test_results)
    
    if not df.empty:
        # Create ExcelWriter with openpyxl engine
        with pd.ExcelWriter(report_path, engine='openpyxl') as writer:
            # Group by Category and create a new sheet for each
            for category in df['Category'].unique():
                category_df = df[df['Category'] == category]
                # Write to Excel, dropping the Category column since the tab name handles it
                category_df.drop(columns=['Category']).to_excel(writer, sheet_name=category, index=False)
        terminalreporter.write_line(f"\n[SUCCESS] Excel Deployable Status Report generated at: {report_path}")
    else:
        # Fallback if no tests were collected or ran
        pd.DataFrame(columns=["Test Name", "Status"]).to_excel(report_path, index=False)
        terminalreporter.write_line(f"\n[WARNING] No tests executed. Empty report created at: {report_path}")

@pytest.fixture(scope="module")
def driver():
    options = UiAutomator2Options()
    current_dir = os.path.dirname(os.path.abspath(__file__))
    apk_path = os.path.join(current_dir, '..', 'build', 'app', 'outputs', 'flutter-apk', 'app-debug.apk')
    
    options.app = apk_path
    options.platform_name = 'Android'
    options.automation_name = 'UiAutomator2'
    options.auto_grant_permissions = True
    options.new_command_timeout = 300
    
    driver = webdriver.Remote('http://127.0.0.1:4723', options=options)
    driver.implicitly_wait(10)
    
    yield driver
    
    driver.quit()
