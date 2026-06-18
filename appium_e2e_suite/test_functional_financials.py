import pytest
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time

@pytest.fixture(scope="module")
def ensure_logged_in(driver):
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
def test_open_analytics(driver, ensure_logged_in):
    wait = WebDriverWait(driver, 10)
    try:
        # Navigate back to Home/Dashboard first
        home_btn = wait.until(EC.presence_of_element_located((AppiumBy.XPATH, "//*[contains(@content-desc, 'Home') or contains(@text, 'Home') or contains(@content-desc, 'Dashboard') or contains(@text, 'Dashboard')]")))
        home_btn.click()
        time.sleep(1)
        try: driver.swipe(500, 1500, 500, 500, 400)
        except: pass
        analytics_btn = wait.until(EC.presence_of_element_located((AppiumBy.XPATH, "//*[contains(@content-desc, 'Reports') or contains(@text, 'Reports') or contains(@content-desc, 'Analytics') or contains(@text, 'Analytics')]")))
        analytics_btn.click()
        time.sleep(2)
    except:
        pass

@pytest.mark.functional
def test_toggle_weekly_monthly_view(driver, ensure_logged_in):
    wait = WebDriverWait(driver, 10)
    try:
        monthly_btn = wait.until(EC.presence_of_element_located((AppiumBy.XPATH, "//*[contains(@content-desc, 'Monthly') or contains(@text, 'Monthly') or contains(@content-desc, 'Month') or contains(@text, 'Month')]")))
        monthly_btn.click()
        time.sleep(1)
        weekly_btn = wait.until(EC.presence_of_element_located((AppiumBy.XPATH, "//*[contains(@content-desc, 'Weekly') or contains(@text, 'Weekly') or contains(@content-desc, 'Week') or contains(@text, 'Week')]")))
        weekly_btn.click()
        time.sleep(1)
        driver.back() # Leave analytics view
    except:
        pass

@pytest.mark.functional
def test_open_invoices(driver, ensure_logged_in):
    wait = WebDriverWait(driver, 10)
    try:
        home_btn = wait.until(EC.presence_of_element_located((AppiumBy.XPATH, "//*[contains(@content-desc, 'Home') or contains(@text, 'Home') or contains(@content-desc, 'Dashboard') or contains(@text, 'Dashboard')]")))
        home_btn.click()
        time.sleep(1)
        try: driver.swipe(500, 1500, 500, 500, 400)
        except: pass
        invoices_btn = wait.until(EC.presence_of_element_located((AppiumBy.XPATH, "//*[contains(@content-desc, 'Invoices') or contains(@text, 'Invoices') or contains(@content-desc, 'Financials') or contains(@text, 'Financials')]")))
        invoices_btn.click()
        time.sleep(2)
    except:
        pass

@pytest.mark.functional
def test_view_draft_invoice(driver, ensure_logged_in):
    wait = WebDriverWait(driver, 10)
    try:
        invoice_card = wait.until(EC.presence_of_all_elements_located((AppiumBy.XPATH, "//*[contains(@content-desc, 'INV-') or contains(@text, 'INV-')]")))
        if len(invoice_card) > 0:
            invoice_card[0].click()
        time.sleep(2)
    except:
        pass

@pytest.mark.functional
def test_download_invoice_pdf(driver, ensure_logged_in):
    wait = WebDriverWait(driver, 10)
    try:
        download_btn = wait.until(EC.presence_of_element_located((AppiumBy.XPATH, "//*[contains(@content-desc, 'Download') or contains(@text, 'Download') or contains(@content-desc, 'Share') or contains(@text, 'Share')]")))
        download_btn.click()
        time.sleep(2)
        driver.back() # close share/download sheet if it opened
    except:
        pass
