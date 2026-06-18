import time
from appium import webdriver
from appium.options.android import UiAutomator2Options
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import os

def create_user(role, name, email, password):
    options = UiAutomator2Options()
    current_dir = os.path.dirname(os.path.abspath(__file__))
    apk_path = os.path.join(current_dir, '..', 'build', 'app', 'outputs', 'flutter-apk', 'app-debug.apk')
    
    options.app = apk_path
    options.platform_name = 'Android'
    options.automation_name = 'UiAutomator2'
    options.auto_grant_permissions = True
    
    try:
        driver = webdriver.Remote('http://127.0.0.1:4723', options=options)
    except Exception as e:
        print("Could not connect to Appium. Is the Appium server running?")
        return

    wait = WebDriverWait(driver, 15)
    
    # Skip onboarding
    time.sleep(5)
    try:
        skip = wait.until(EC.presence_of_element_located((AppiumBy.XPATH, "//*[contains(@content-desc, 'Skip') or contains(@text, 'Skip')]")))
        skip.click()
        time.sleep(2)
    except: pass
    
    # Go to Sign up
    try:
        signup_btn = wait.until(EC.presence_of_element_located((AppiumBy.XPATH, "//*[contains(@content-desc, 'Sign up') or contains(@text, 'Sign up')]")))
        signup_btn.click()
        time.sleep(2)
    except: pass
    
    # Fill Sign Up form
    try:
        if role == 'Client':
            client_btn = wait.until(EC.presence_of_element_located((AppiumBy.XPATH, "//*[contains(@content-desc, 'Client') or contains(@text, 'Client')]")))
            client_btn.click()
            time.sleep(1)
            
        edit_texts = wait.until(EC.presence_of_all_elements_located((AppiumBy.CLASS_NAME, "android.widget.EditText")))
        if len(edit_texts) >= 4:
            edit_texts[0].click()
            edit_texts[0].send_keys(name)
            
            edit_texts[1].click()
            edit_texts[1].send_keys(email)
            
            edit_texts[2].click()
            edit_texts[2].send_keys(password)
            
            edit_texts[3].click()
            edit_texts[3].send_keys(password)
            
            try: driver.hide_keyboard()
            except: pass
            
        create_btn = driver.find_element(AppiumBy.XPATH, "//*[contains(@content-desc, 'Create Account') or contains(@text, 'Create Account')]")
        create_btn.click()
        time.sleep(5)
        print(f"Created {role}: {email}")
    except Exception as e:
        print(f"Error creating {email}: (User might already exist or UI changed) {e}")
    finally:
        driver.quit()

if __name__ == '__main__':
    print("Creating Freelancer...")
    create_user('Freelancer', 'Test Freelancer', 'muralikishore123456@gmail.com', '12345678')
    print("Creating Client...")
    create_user('Client', 'Test Client', 'murali123@gmail.com', '12345678')
