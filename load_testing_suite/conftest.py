import pytest
import pandas as pd
import os

test_results = []

@pytest.hookimpl(tryfirst=True, hookwrapper=True)
def pytest_runtest_makereport(item, call):
    outcome = yield
    report = outcome.get_result()
    
    if report.when == "call":
        # Extract the performance data we injected via the fixture
        perf_data = getattr(item, 'perf_data', None)
        if perf_data:
            perf_data['Result'] = "PASS" if report.outcome == "passed" else "FAIL"
            if report.outcome != "passed":
                perf_data['Score (0-100)'] = max(0, perf_data['Score (0-100)'] - 30) # Penalize fail
            test_results.append(perf_data)

def pytest_sessionfinish(session, exitstatus):
    reports_dir = os.path.join(os.path.dirname(__file__), 'reports')
    os.makedirs(reports_dir, exist_ok=True)
    report_path = os.path.join(reports_dir, 'Load_Test_Report.xlsx')
    
    df = pd.DataFrame(test_results)
    if not df.empty:
        # Ensure exact column order requested
        cols = ['Test Case', 'Category', 'Performance Metric', 'Measured Value', 'Threshold', 'Score (0-100)', 'Result']
        df = df[cols]
        
        with pd.ExcelWriter(report_path, engine='openpyxl') as writer:
            df.to_excel(writer, sheet_name='Performance Metrics', index=False)
            
            # Format the spreadsheet for readability
            worksheet = writer.sheets['Performance Metrics']
            for col in worksheet.columns:
                max_length = 0
                column = col[0].column_letter
                for cell in col:
                    try:
                        if len(str(cell.value)) > max_length:
                            max_length = len(str(cell.value))
                    except:
                        pass
                adjusted_width = (max_length + 2)
                worksheet.column_dimensions[column].width = adjusted_width
                
        print(f"\n[SUCCESS] Load Test Excel Report generated at: {report_path}")
    else:
        print(f"\n[WARNING] No tests executed. Report not generated.")
