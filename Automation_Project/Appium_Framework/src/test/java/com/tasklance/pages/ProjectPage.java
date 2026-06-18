package com.tasklance.pages;

import io.appium.java_client.android.AndroidDriver;
import io.appium.java_client.pagefactory.AndroidFindBy;
import org.openqa.selenium.WebElement;

public class ProjectPage extends BasePage {

    @AndroidFindBy(accessibility = "Search projects")
    private WebElement searchInput;

    @AndroidFindBy(xpath = "//android.widget.TextView[@text='Create Project']")
    private WebElement createProjectButton;

    @AndroidFindBy(accessibility = "Project Title")
    private WebElement projectTitleField;

    @AndroidFindBy(accessibility = "Submit Proposal")
    private WebElement submitProposalButton;

    public ProjectPage(AndroidDriver driver) {
        super(driver);
    }

    public void searchProject(String name) {
        sendKeys(searchInput, name);
    }

    public void clickCreateProject() {
        click(createProjectButton);
    }
}
