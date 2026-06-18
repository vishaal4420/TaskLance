package com.tasklance.pages;

import io.appium.java_client.android.AndroidDriver;
import io.appium.java_client.pagefactory.AndroidFindBy;
import org.openqa.selenium.WebElement;

public class LoginPage extends BasePage {

    @AndroidFindBy(accessibility = "email_field")
    private WebElement emailField;

    @AndroidFindBy(accessibility = "password_field")
    private WebElement passwordField;

    @AndroidFindBy(accessibility = "login_button")
    private WebElement loginButton;

    @AndroidFindBy(accessibility = "Sign up")
    private WebElement signUpLink;

    public LoginPage(AndroidDriver driver) {
        super(driver);
    }

    public void login(String email, String password) {
        sendKeys(emailField, email);
        sendKeys(passwordField, password);
        click(loginButton);
    }

    public void goToSignUp() {
        click(signUpLink);
    }
}
