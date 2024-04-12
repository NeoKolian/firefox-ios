// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import XCTest

class SettingsTests: BaseTestCase {
    private func checkShowImages(showImages: Bool = true) {
        let noImageStatusMode = app.otherElements.tables.cells.switches["NoImageModeStatus"]
        mozWaitForElementToExist(noImageStatusMode)
        if showImages {
            XCTAssertEqual(noImageStatusMode.value as! String, "0")
        } else {
            XCTAssertEqual(noImageStatusMode.value as! String, "1")
        }
    }

    // https://testrail.stage.mozaws.net/index.php?/cases/view/2334757
    func testHelpOpensSUMOInTab() {
        navigator.nowAt(NewTabScreen)
        navigator.goto(SettingsScreen)
        let settingsTableView = app.tables[AccessibilityIdentifiers.Settings.tableViewController]

        while settingsTableView.staticTexts["Help"].exists == false {
            settingsTableView.swipeUp()
        }
        let helpMenu = settingsTableView.cells["Help"]
        XCTAssertTrue(helpMenu.isEnabled)
        helpMenu.tap()

        waitUntilPageLoad()
        mozWaitForValueContains(app.textFields["url"], value: "support.mozilla.org")
        mozWaitForElementToExist(app.webViews.staticTexts["Firefox for iOS Support"])

        let numTabs = app.buttons["Show Tabs"].value
        XCTAssertEqual("2", numTabs as? String, "Sume should be open in a different tab")
    }

    // https://testrail.stage.mozaws.net/index.php?/cases/view/2334760
    func testOpenSiriOption() {
        waitForTabsButton()
        navigator.nowAt(NewTabScreen)
        navigator.performAction(Action.OpenSiriFromSettings)
        mozWaitForElementToExist(app.cells["SiriSettings"], timeout: 5)
    }

    // https://testrail.stage.mozaws.net/index.php?/cases/view/2334756
    func testCopiedLinks() {
        navigator.nowAt(NewTabScreen)
        navigator.goto(SettingsScreen)

        // Check Offer to open copied links, when opening firefox is off
        let value = app.tables.cells.switches["Offer to Open Copied Links, When Opening Firefox"].value
        XCTAssertEqual(value as? String, "0")

        // Switch on, Offer to open copied links, when opening firefox
        app.tables.cells.switches["Offer to Open Copied Links, When Opening Firefox"].tap()

        // Check Offer to open copied links, when opening firefox is on
        let value2 = app.tables.cells.switches["Offer to Open Copied Links, When Opening Firefox"].value
        XCTAssertEqual(value2 as? String, "1")

        app.navigationBars["Settings"].buttons["Done"].tap()

        app.buttons[AccessibilityIdentifiers.Toolbar.settingsMenuButton].tap()
        let settingsmenuitemCell = app.tables.otherElements["Settings"]
        settingsmenuitemCell.tap()

        // Check Offer to open copied links, when opening firefox is on
        let value3 = app.tables.cells.switches["Offer to Open Copied Links, When Opening Firefox"].value
        XCTAssertEqual(value3 as? String, "1")
    }

    // https://testrail.stage.mozaws.net/index.php?/cases/view/2307041
    func testOpenMailAppSettings() {
        waitForTabsButton()
        navigator.nowAt(NewTabScreen)
        navigator.goto(OpenWithSettings)

        // Check that the list is shown
        mozWaitForElementToExist(app.tables["OpenWithPage.Setting.Options"])
        XCTAssertTrue(app.tables["OpenWithPage.Setting.Options"].exists)

        // Check that the list is shown with all elements disabled
        XCTAssertTrue(app.tables.staticTexts["OPEN MAIL LINKS WITH"].exists)
        XCTAssertFalse(app.tables.cells.staticTexts["Mail"].isSelected)
        XCTAssertFalse(app.tables.cells.staticTexts["Outlook"].isSelected)
        XCTAssertFalse(app.tables.cells.staticTexts["ProtonMail"].isSelected)
        XCTAssertFalse(app.tables.cells.staticTexts["Airmail"].isSelected)
        XCTAssertFalse(app.tables.cells.staticTexts["myMail"].isSelected)
        XCTAssertFalse(app.tables.cells.staticTexts["Spark"].isSelected)
        XCTAssertFalse(app.tables.cells.staticTexts["YMail!"].isSelected)
        XCTAssertFalse(app.tables.cells.staticTexts["Gmail"].isSelected)
        XCTAssertFalse(app.tables.cells.staticTexts["Fastmail"].isSelected)

        // Check that tapping on an element does nothing
        mozWaitForElementToExist(app.tables["OpenWithPage.Setting.Options"])
        app.tables.cells.staticTexts["Airmail"].tap()
        XCTAssertFalse(app.tables.cells.staticTexts["Airmail"].isSelected)

        // Check that user can go back from that setting
        navigator.nowAt(OpenWithSettings)
        navigator.goto(SettingsScreen)
    }

    // https://testrail.stage.mozaws.net/index.php?/cases/view/2307058
    // Functionality is tested by UITests/NoImageModeTests, here only the UI is updated properly
    // SmokeTest
    func testImageOnOff() {
        // Select no images or hide images, check it's hidden or not
        waitUntilPageLoad()

        // Select hide images
        let blockImagesSwitch = app.otherElements.tables.cells.switches[
            AccessibilityIdentifiers.Settings.BlockImages.title
        ]
        navigator.goto(SettingsScreen)
        navigator.nowAt(SettingsScreen)
        mozWaitForElementToExist(blockImagesSwitch)
        navigator.performAction(Action.ToggleNoImageMode)
        checkShowImages(showImages: false)

        // Select show images
        navigator.goto(SettingsScreen)
        navigator.nowAt(SettingsScreen)
        mozWaitForElementToExist(blockImagesSwitch)
        navigator.performAction(Action.ToggleNoImageMode)
        checkShowImages(showImages: true)
    }

    // https://testrail.stage.mozaws.net/index.php?/cases/view/2306808
    // Smoketest
    func testSettingsOptionSubtitles() {
        mozWaitForElementToExist(app.buttons[AccessibilityIdentifiers.Toolbar.settingsMenuButton], timeout: TIMEOUT)
        navigator.nowAt(NewTabScreen)
        navigator.goto(SettingsScreen)
        let table = app.tables.element(boundBy: 0)
        let settingsQuery = AccessibilityIdentifiers.Settings.self
        mozWaitForElementToExist(table)
        let settingsElements = [
            // There are elements that have missing identifiers. Test will be updated once these will be added
            // https://github.com/mozilla-mobile/firefox-ios/issues/19729
            table.cells[settingsQuery.DefaultBrowser.defaultBrowser], table.cells[settingsQuery.ConnectSetting.title],
            table.cells[settingsQuery.Search.title], table.cells[settingsQuery.NewTab.title],
            table.cells[settingsQuery.Homepage.homeSettings], table.cells[settingsQuery.Tabs.title],
            table.cells[settingsQuery.OpenWithMail.title], table.cells[settingsQuery.Theme.title],
            table.cells[settingsQuery.SearchBar.searchBarSetting], table.cells[settingsQuery.Siri.title],
            table.cells[settingsQuery.BlockPopUp.title], table.cells[settingsQuery.NoImageMode.title],
            app.switches[settingsQuery.OfferToOpen.title], table.cells[settingsQuery.Logins.title],
            app.switches[settingsQuery.ShowLink.title], table.cells[settingsQuery.CreditCards.title],
            table.cells[settingsQuery.Address.title], table.cells[settingsQuery.ClearData.title],
            app.switches[settingsQuery.ClosePrivateTabs.title], table.cells[settingsQuery.ContentBlocker.title],
            table.cells[settingsQuery.Notifications.title], table.cells[settingsQuery.ShowIntroduction.title],
            table.cells[settingsQuery.SendAnonymousUsageData.title], table.cells[settingsQuery.StudiesToggle.title],
            table.cells[settingsQuery.Version.title], table.cells["Privacy Policy"],
            table.cells["Send Feedback"], table.cells["Help"], table.cells["Rate on App Store"],
            table.cells["Licenses"], table.cells["Your Rights"]
        ]

        for i in settingsElements {
            scrollToElement(i)
            mozWaitForElementToExist(i)
            XCTAssertTrue(i.isVisible())
        }
    }
}
