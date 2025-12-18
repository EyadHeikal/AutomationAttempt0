// ~/.finicky.js
export default {
  // Make *this* your global default
  // defaultBrowser: { name: "Chromium", profile: "Profile 4" },
  // defaultBrowser: { name: "FireFox" , profile: "Default Profile" },
  defaultBrowser: { name: "Google Chrome", profile: "Default" },
  handlers: [
    {
      match: [
        "*instabug.atlassian.net/*",
        "*claude.ai/*",
        "*cursor.com*",
        "*codelayer*",
        "*circleci.com*"
        // "*exuberant-tiger-62.authkit.app/*",
        // "*https://accounts.google.com/*"

      ],
      browser: {
        name: "Google Chrome",
        profile: "Profile 1"
      }
    },
    {
      match: [
        "*youtube.com*",
      ],
      browser: {
        name: "FireFox",
        profile: "Default Profile"
      }
    },
  ],
  options: {
    // if you ever keep Finicky running, this hides the menu-bar icon
    keepRunning: false,
    hideIcon: true
  },
  // (Optional) more rules per app/domain here...
};
