import subprocess
import json
import pandas as pd
from datetime import datetime

def run_tests():
    print("Starting Flutter Integration Tests...")
    
    # Run the flutter test command with machine-readable output
    # Since it might fail (return non-zero), we don't check=True immediately
    result = subprocess.run(
        ["flutter", "test", "integration_test/app_test.dart", "-d", "windows", "--machine"],
        capture_output=True,
        text=True,
        shell=True
    )
    
    records = []
    
    # Parse the machine output
    for line in result.stdout.split('\n'):
        if not line.strip():
            continue
        if line.startswith('[{') or line.startswith('{'):
            try:
                # Sometimes flutter outputs arrays of JSON objects, sometimes single ones
                data = json.loads(line)
                if isinstance(data, list):
                    for item in data:
                        process_event(item, records)
                else:
                    process_event(data, records)
            except json.JSONDecodeError:
                pass
                
    # If we didn't parse anything properly or command totally failed, 
    # we can add a row for the overall process
    if not records and result.returncode != 0:
        records.append({
            "Test Name": "App Test Execution",
            "Status": "FAIL",
            "Error Details": result.stderr or "Unknown Execution Error",
            "Timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        })
        
    # Generate Excel Report
    df = pd.DataFrame(records)
    
    # If the dataframe is empty, we just put a placeholder
    if df.empty:
        df = pd.DataFrame([{
            "Test Name": "All Tests",
            "Status": "UNKNOWN",
            "Error Details": "No tests reported",
            "Timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }])
        
    excel_file = "TaskLance_Test_Report.xlsx"
    df.to_excel(excel_file, index=False)
    
    print(f"Test execution finished. Report generated: {excel_file}")
    
    if result.returncode != 0:
        print("There were test failures.")
        exit(1)
    else:
        print("All tests passed successfully.")

# We keep a mapping of test ID to test name
test_names = {}

def process_event(event, records):
    if not isinstance(event, dict):
        return
        
    event_type = event.get("event")
    
    if event_type == "testStart":
        test = event.get("test", {})
        test_id = test.get("id")
        name = test.get("name", "Unknown Test")
        test_names[test_id] = name
        
    elif event_type == "testDone":
        test_id = event.get("testID")
        result = event.get("result", "unknown")
        
        # We only care about actual tests, skip the hidden/internal ones
        name = test_names.get(test_id, "Unknown Test")
        if name.startswith("loading ") or name == "Unknown Test":
            return
            
        status = "PASS" if result == "success" else "FAIL"
        error = event.get("error", "") if status == "FAIL" else ""
        
        records.append({
            "Test Name": name,
            "Status": status,
            "Error Details": error,
            "Timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        })

if __name__ == "__main__":
    run_tests()
