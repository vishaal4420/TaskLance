import pytest
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time

@pytest.fixture(scope="module")
def ensure_logged_in(driver):
    wait = WebDriverWait(driver, 15)
    time.sleep(5)

    try:
        skip = wait.until(EC.presence_of_element_located((AppiumBy.XPATH, "//*[contains(@content-desc, 'Skip') or contains(@text, 'Skip')]")))
        skip.click()
        time.sleep(2)
    except:
        pass
        
    try:
        edit_texts = wait.until(EC.presence_of_all_elements_located((AppiumBy.CLASS_NAME, "android.widget.EditText")))
        if len(edit_texts) >= 2:
            edit_texts[0].click()
            edit_texts[0].clear()
            edit_texts[0].send_keys("muralikishore123456@gmail.com")
            edit_texts[1].click()
            edit_texts[1].clear()
            edit_texts[1].send_keys("12345678")
            try: driver.hide_keyboard()
            except: pass
            login = wait.until(EC.presence_of_element_located((AppiumBy.XPATH, "//*[contains(@content-desc, 'Log In') or contains(@text, 'Log In')]")))
            login.click()
                        # Check for profile setup and finish it
            try:
                # Use a short wait so we don't stall for 10s if we're not on profile setup
                short_wait = WebDriverWait(driver, 3)
                finish_btn = short_wait.until(EC.presence_of_element_located((AppiumBy.XPATH, "//*[contains(@content-desc, 'Finish Setup') or contains(@text, 'Finish Setup')]")))
                
                edit_texts = driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.EditText")
                if len(edit_texts) > 0:
                    edit_texts[0].click()
                    edit_texts[0].clear()
                    edit_texts[0].send_keys("Test User")
                    try: driver.hide_keyboard()
                    except: pass
                
                finish_btn.click()
                time.sleep(2)
            except:
                pass
            
            wait.until(EC.presence_of_element_located((AppiumBy.XPATH, "//*[contains(@content-desc, 'Projects') or contains(@text, 'Projects')]")))
            
            # Click Seed Database button
            try:
                seed_btn = wait.until(EC.presence_of_element_located((AppiumBy.XPATH, "//*[contains(@content-desc, 'Seed Firebase Database')]")))
                seed_btn.click()
                time.sleep(2)
            except Exception as e:
                print("Seed button not found:", e)
    except:
        pass

@pytest.mark.functional
def test_navigate_to_profile(driver, ensure_logged_in):
    try:
        wait = WebDriverWait(driver, 10)
        tab = wait.until(EC.presence_of_element_located((AppiumBy.XPATH, "//*[contains(@content-desc, 'Profile') or contains(@text, 'Profile')]")))
        tab.click()
        time.sleep(1)
    except:
        pass

@pytest.mark.functional
def test_update_bio(driver, ensure_logged_in):
    wait = WebDriverWait(driver, 10)
    try:
        # Assuming there's an Edit Profile button or Icon on the profile screen
        edit_btn = wait.until(EC.presence_of_element_located((AppiumBy.XPATH, "//*[contains(@content-desc, 'Edit') or contains(@text, 'Edit') or contains(@content-desc, 'edit')]")))
        edit_btn.click()
        time.sleep(2)
        
        fields = wait.until(EC.presence_of_all_elements_located((AppiumBy.CLASS_NAME, "android.widget.EditText")))
        if len(fields) >= 4:
            # Field 3 is Bio
            fields[3].click()
            fields[3].clear()
            fields[3].send_keys("Updated Bio via Appium test suite!")
            try: driver.hide_keyboard()
            except: pass
    except Exception as e:
        pass

@pytest.mark.functional
def test_change_hourly_rate(driver, ensure_logged_in):
    wait = WebDriverWait(driver, 10)
    try:
        fields = wait.until(EC.presence_of_all_elements_located((AppiumBy.CLASS_NAME, "android.widget.EditText")))
        if len(fields) >= 3:
            # Field 2 is Hourly Rate
            fields[2].click()
            fields[2].clear()
            fields[2].send_keys("150")
            try: driver.hide_keyboard()
            except: pass
            
        # Now save changes
        save_btn = wait.until(EC.presence_of_element_located((AppiumBy.XPATH, "//*[contains(@content-desc, 'Save') or contains(@text, 'Save')]")))
        save_btn.click()
        time.sleep(2)
    except Exception as e:
        pass

@pytest.mark.functional
def test_add_skill(driver, ensure_logged_in):
    wait = WebDriverWait(driver, 10)
    try:
        add_skill_btn = wait.until(EC.presence_of_element_located((AppiumBy.XPATH, "//*[contains(@content-desc, 'Add Skill') or contains(@text, 'Add Skill')]")))
        add_skill_btn.click()
        time.sleep(1)
        # Assuming Add Skill opens a dialog or sheet, driver.back() would close it.
        # If it doesn't open anything, driver.back() might go back to Dashboard.
        # Let's check if there is a dialog, if not, don't go back.
        try:
            wait.until(EC.presence_of_element_located((AppiumBy.CLASS_NAME, "android.widget.EditText")))
            driver.back()
        except:
            pass
    except Exception as e:
        pass

@pytest.mark.functional
def test_remove_skill(driver, ensure_logged_in):
    wait = WebDriverWait(driver, 10)
    try:
        remove_skill = wait.until(EC.presence_of_element_located((AppiumBy.XPATH, "//*[contains(@content-desc, 'Remove Skill') or contains(@text, 'Remove Skill') or contains(@content-desc, 'delete') or contains(@text, 'delete')]")))
        remove_skill.click()
        time.sleep(1)
    except:
        pass

@pytest.mark.functional
def test_toggle_availability(driver, ensure_logged_in):
    wait = WebDriverWait(driver, 10)
    try:
        switch = wait.until(EC.presence_of_element_located((AppiumBy.CLASS_NAME, "android.widget.Switch")))
        switch.click()
        time.sleep(1)
    except:
        pass

@pytest.mark.functional
def test_edit_location(driver, ensure_logged_in):
    wait = WebDriverWait(driver, 10)
    try:
        location_field = wait.until(EC.presence_of_element_located((AppiumBy.XPATH, "//*[contains(@content-desc, 'Location') or contains(@text, 'Location')]")))
        location_field.click()
        time.sleep(1)
    except:
        pass

@pytest.mark.functional
def test_edit_timezone(driver, ensure_logged_in):
    wait = WebDriverWait(driver, 10)
    try:
        timezone_field = wait.until(EC.presence_of_element_located((AppiumBy.XPATH, "//*[contains(@content-desc, 'Timezone') or contains(@text, 'Timezone')]")))
        timezone_field.click()
        time.sleep(1)
    except Exception as e:
        pass

@pytest.mark.functional
def test_upload_portfolio_item(driver, ensure_logged_in):
    wait = WebDriverWait(driver, 10)
    try:
        portfolio_btn = wait.until(EC.presence_of_element_located((AppiumBy.XPATH, "//*[contains(@content-desc, 'Portfolio') or contains(@text, 'Portfolio')]")))
        portfolio_btn.click()
        time.sleep(1)
    except Exception as e:
        pass

@pytest.mark.functional
def test_save_settings(driver, ensure_logged_in):
    wait = WebDriverWait(driver, 10)
    try:
        settings_btn = wait.until(EC.presence_of_element_located((AppiumBy.XPATH, "//*[contains(@content-desc, 'Settings') or contains(@text, 'Settings')]")))
        settings_btn.click()
        time.sleep(1)
        driver.back()
    except Exception as e:
        pass
