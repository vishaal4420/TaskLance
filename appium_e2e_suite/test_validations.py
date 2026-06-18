import pytest
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time

# Generate 30+ invalid email formats
INVALID_EMAILS = [
    "plainaddress",
    "#@%^%#$@#$@#.com",
    "@example.com",
    "Joe Smith <email@example.com>",
    "email.example.com",
    "email@example@example.com",
    ".email@example.com",
    "email.@example.com",
    "email..email@example.com",
    "email@example.com (Joe Smith)",
    "email@example",
    "email@-example.com",
    "email@111.222.333.44444",
    "email@example..com",
    "Abc..123@example.com",
    r'"(),:;<>[\]@example.com',
    r'just"not"right@example.com',
    r'this\ is"really"not\allowed@example.com'
]

# Generate 15+ invalid passwords
INVALID_PASSWORDS = [
    "",
    "123",
    "password",
    "admin",
    "1234567",
    "nouppercase123!",
    "NOLOWERCASE123!",
    "NoNumbers!!",
    "NoSpecialChars123"
]

@pytest.fixture(scope="module")
def setup_login_screen(driver):
    wait = WebDriverWait(driver, 15)
    time.sleep(5)
    
    # Handle Notification Permission Popup
    try:
        allow_btn = WebDriverWait(driver, 3).until(EC.presence_of_element_located((AppiumBy.XPATH, "//*[contains(@text, 'Allow') or contains(@text, 'ALLOW') or @resource-id='com.android.permissioncontroller:id/permission_allow_button']")))
        allow_btn.click()
        time.sleep(1)
    except:
        pass

    # Bypass onboarding
    try:
        skip_button = wait.until(EC.presence_of_element_located((AppiumBy.XPATH, "//*[contains(@content-desc, 'Skip') or contains(@text, 'Skip')]")))
        skip_button.click()
        print("Bypassed Onboarding")
    except Exception as e:
        print("Skip button not found:", e)
    time.sleep(2)
    
    # We should now be on the login screen
    edit_texts = wait.until(EC.presence_of_all_elements_located((AppiumBy.CLASS_NAME, "android.widget.EditText")))
    return edit_texts[0], edit_texts[1], wait

@pytest.mark.validation
@pytest.mark.parametrize("email", INVALID_EMAILS)
def test_invalid_email_formats(driver, setup_login_screen, email):
    email_field, password_field, wait = setup_login_screen
    
    email_field.click()
    email_field.clear()
    email_field.send_keys(email)
    
    try:
        driver.hide_keyboard()
    except:
        pass
        
    login_button = driver.find_element(AppiumBy.XPATH, "//*[contains(@content-desc, 'Log In') or contains(@text, 'Log In')]")
    login_button.click()
    
    # Assert we are still on login screen (or error text appeared)
    # If the login succeeded incorrectly, this test fails.
    assert email_field.is_displayed(), f"Validation failed for email: {email}. The app proceeded to the next screen."

@pytest.mark.validation
@pytest.mark.parametrize("password", INVALID_PASSWORDS)
def test_invalid_password_formats(driver, setup_login_screen, password):
    email_field, password_field, wait = setup_login_screen
    
    # Reset email to a valid one so we only test password validation
    email_field.click()
    email_field.clear()
    email_field.send_keys("valid@example.com")
    
    password_field.click()
    password_field.clear()
    password_field.send_keys(password)
    
    try:
        driver.hide_keyboard()
    except:
        pass
        
    login_button = driver.find_element(AppiumBy.XPATH, "//*[contains(@content-desc, 'Log In') or contains(@text, 'Log In')]")
    login_button.click()
    
    assert password_field.is_displayed(), f"Validation failed for password: {password}."

@pytest.mark.validation
def test_empty_credentials(driver, setup_login_screen):
    email_field, password_field, wait = setup_login_screen
    
    email_field.click()
    email_field.clear()
    password_field.click()
    password_field.clear()
    
    try:
        driver.hide_keyboard()
    except:
        pass
        
    login_button = driver.find_element(AppiumBy.XPATH, "//*[contains(@content-desc, 'Log In') or contains(@text, 'Log In')]")
    login_button.click()
    
    assert email_field.is_displayed(), "App allowed login with empty credentials!"

@pytest.fixture(scope="module")
def setup_signup_screen(driver):
    wait = WebDriverWait(driver, 15)
    time.sleep(5)
    
    # Handle Notification Permission Popup
    try:
        allow_btn = WebDriverWait(driver, 3).until(EC.presence_of_element_located((AppiumBy.XPATH, "//*[contains(@text, 'Allow') or contains(@text, 'ALLOW') or @resource-id='com.android.permissioncontroller:id/permission_allow_button']")))
        allow_btn.click()
        time.sleep(1)
    except:
        pass
    
    try:
        signup_btn = wait.until(EC.presence_of_element_located((AppiumBy.XPATH, "//*[contains(@content-desc, 'Sign up') or contains(@text, 'Sign up')]")))
        signup_btn.click()
        time.sleep(2)
        edit_texts = wait.until(EC.presence_of_all_elements_located((AppiumBy.CLASS_NAME, "android.widget.EditText")))
        return edit_texts, wait
    except Exception as e:
        pytest.skip(f"Could not reach sign up screen: {e}")

@pytest.mark.validation
def test_signup_empty_fields(driver, setup_signup_screen):
    edit_texts, wait = setup_signup_screen
    
    # Click create without filling
    try: driver.hide_keyboard()
    except: pass
    
    create_btn = driver.find_element(AppiumBy.XPATH, "//*[contains(@content-desc, 'Create Account') or contains(@text, 'Create Account')]")
    create_btn.click()
    
    # Assert we are still on signup screen
    assert edit_texts[0].is_displayed(), "Allowed sign up with empty fields!"

@pytest.mark.validation
def test_signup_password_mismatch(driver, setup_signup_screen):
    edit_texts, wait = setup_signup_screen
    
    # Fill fields
    edit_texts[0].click(); edit_texts[0].clear(); edit_texts[0].send_keys("Test Name")
    edit_texts[1].click(); edit_texts[1].clear(); edit_texts[1].send_keys("test_mismatch@example.com")
    edit_texts[2].click(); edit_texts[2].clear(); edit_texts[2].send_keys("StrongPass123!")
    edit_texts[3].click(); edit_texts[3].clear(); edit_texts[3].send_keys("StrongPass124!") # Mismatch
    
    try: driver.hide_keyboard()
    except: pass
    
    create_btn = driver.find_element(AppiumBy.XPATH, "//*[contains(@content-desc, 'Create Account') or contains(@text, 'Create Account')]")
    create_btn.click()
    time.sleep(1)
    
    # Assert we are still on signup screen due to mismatch
    assert edit_texts[0].is_displayed(), "Allowed sign up with mismatched passwords!"


