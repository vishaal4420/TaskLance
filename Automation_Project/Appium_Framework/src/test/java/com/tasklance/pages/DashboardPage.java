package com.tasklance.pages;

import io.appium.java_client.android.AndroidDriver;
import io.appium.java_client.pagefactory.AndroidFindBy;
import org.openqa.selenium.WebElement;

public class DashboardPage extends BasePage {

    @AndroidFindBy(accessibility = "New Invoice")
    private WebElement newInvoiceButton;

    @AndroidFindBy(accessibility = "search")
    private WebElement searchButton;

    @AndroidFindBy(accessibility = "notifications_outlined")
    private WebElement notificationsButton;

    @AndroidFindBy(accessibility = "Find Work")
    private WebElement findWorkButton;

    @AndroidFindBy(accessibility = "Invoices")
    private WebElement invoicesButton;

    @AndroidFindBy(xpath = "//android.widget.ImageView[contains(@content-desc, 'Avatar')]")
    private WebElement profileAvatar;

    public DashboardPage(AndroidDriver driver) {
        super(driver);
    }

    public void clickNewInvoice() {
        click(newInvoiceButton);
    }

    public void openProfile() {
        click(profileAvatar);
    }

    public void goToFindWork() {
        click(findWorkButton);
    }
}
