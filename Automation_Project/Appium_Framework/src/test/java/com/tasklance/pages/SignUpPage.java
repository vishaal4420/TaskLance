package com.tasklance.pages;

import io.appium.java_client.android.AndroidDriver;
import io.appium.java_client.pagefactory.AndroidFindBy;
import org.openqa.selenium.WebElement;

public class SignUpPage extends BasePage {

    @AndroidFindBy(accessibility = "Full Name")
    private WebElement fullNameField;

    @AndroidFindBy(accessibility = "Email")
    private WebElement emailField;

    @AndroidFindBy(accessibility = "Password")
    private WebElement passwordField;

    @AndroidFindBy(accessibility = "Confirm Password")
    private WebElement confirmPasswordField;

    @AndroidFindBy(accessibility = "Create Account")
    private WebElement createAccountButton;

    public SignUpPage(AndroidDriver driver) {
        super(driver);
    }

    public void signUp(String name, String email, String password) {
        sendKeys(fullNameField, name);
        sendKeys(emailField, email);
        sendKeys(passwordField, password);
        sendKeys(confirmPasswordField, password);
        click(createAccountButton);
    }
}
