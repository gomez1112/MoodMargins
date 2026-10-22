import Testing
@testable import MoodMargins

@MainActor
struct NavigationContextTests {
    @Test func windowsKeepIndependentTabsAndPresentations() {
        let first = NavigationContext()
        let second = NavigationContext()

        first.selectTab(.insights)
        first.presentSheet(.plus)

        #expect(first.selectedTab == .insights)
        #expect(first.presentedSheet == .plus)
        #expect(second.selectedTab == .today)
        #expect(second.presentedSheet == nil)
        second.selectTab(.page)
        #expect(first.selectedTab == .insights)
    }

    @Test func browsingFromTodayRequestsTheBrowserOnlyInThatWindow() {
        let first = NavigationContext()
        let second = NavigationContext()
        first.browsePages()
        #expect(first.selectedTab == .page)
        #expect(first.isPageBrowserRequested)
        #expect(!second.isPageBrowserRequested)
        #expect(second.selectedTab == .today)
    }
}
