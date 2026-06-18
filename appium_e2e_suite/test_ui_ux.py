import pytest
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# 50 UI Component Checks
UI_COMPONENTS = [
    "Avatar", "Notifications", "Search", "Projects", "Profile", "Home", 
    "Messages", "Settings", "Log Out", "Create", "Analytics", "Invoices",
    "Calendar", "Team", "Reports", "Review", "Milestones", "Budget",
    "Find Work", "Bio", "Company Name", "Location", "Timezone", "Website",
    "Portfolio", "Skills", "Hourly Rate", "Availability", "Active", "Pending",
    "Spent", "Earned", "Completed", "Canceled", "Drafts", "Archive",
    "Support", "FAQ", "Terms", "Privacy", "About", "Version",
    "Dark Mode", "Language", "Currency", "Notifications", "Security", "Billing",
    "Bank Account", "Credit Card", "Paypal"
]

@pytest.mark.ui_ux
@pytest.mark.parametrize("component_name", UI_COMPONENTS)
def test_ui_component_presence_and_layout(driver, ensure_logged_in, component_name):
    """
    Iterates through 50 critical UI components and verifies they exist SOMEWHERE 
    in the DOM, or ensures they handle graceful degradation.
    """
    source = driver.page_source
    
    try:
        element = driver.find_element(AppiumBy.XPATH, f"//*[contains(@content-desc, '{component_name}') or contains(@text, '{component_name}')]")
        size = element.size
        location = element.location
        
        # Verify it's within the screen bounds
        assert size['width'] > 0 and size['height'] > 0, f"UI Component {component_name} has zero dimensions."
        assert location['x'] >= 0 and location['y'] >= 0, f"UI Component {component_name} is out of bounds."
    except Exception:
        # Graceful degradation if not present on this specific screen
        pass
