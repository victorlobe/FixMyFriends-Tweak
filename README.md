<p align="center">
  <img width="120" height="120" alt="FixMyFriendsIcon" src="https://github.com/user-attachments/assets/f452264d-63f0-4fe7-b380-ab2d80a6e1a4" />
</p>

<h1 align="center">FixMyFriends</h1>

<p align="center">
  Fix Find My Friends on iOS 5 & 6!
</p>

<p align="center">
  <a href="https://github.com/victorlobe/FixMyFriends/releases/latest">
    <img alt="Download" src="https://img.shields.io/badge/download-latest-blue?logo=apple" />
  </a>
  <img alt="License" src="https://img.shields.io/badge/license-MIT-green">
  <img alt="Platform" src="https://img.shields.io/badge/platform-iOS%205+-007AFF">
</p>

---

## Features

- Fixes Find My Friends on iOS 5 & 6

## Requirements

- iOS 5.1+
- Find my Friends version 1.0+ (tested with versions 1.0, 2.1 and 2.1.1)
- MobileSubstrate
- Root certificates from tlsroot.litten.ca

## Installation

1. **Add the repo** `repo.victorlobe.me` to Cydia

3. **Install FixMyFriends**

4. **Respring your device**

5. **Launch Find My Friends**

6. **Type in your Apple ID and Password**

7. **There will be an error that your password was incorrect, that's normal. Tap "OK".**

8. **You received a code on your modern Apple devices for 2 Factor Auth. Type in your password in Find My Friends again and after your password type the code. E.g. Password -> Password123456**

9. **Tap "Sign In".**

10. **Congratulations! You can now stalk your friends location via your legacy devices!**


## Manual Installation

1. Download the `.deb` file

3. Install using `dpkg -i FixMyFriends.deb`

4. Respring your device

## Version History

### v1.0.0
- Initial release

## To Do

- [ ] Fix some contact names not being displayed properly.
- [ ] Find a better way for the random "Sign in required" message that appears after the user manually signs out of the app.

## Behind the Scenes

The tweak hooks into Find My Friends and modifies outgoing network requests to make them appear as if they're coming from iOS 7. This allows the iOS 5 & 6 versions of the app to work with modern iCloud servers that have dropped support for these older versions because *Spoiler*: The App works perfectly fine, just like on iOS 7, but Apple likes to block things.

**Technical Details:**
- Modifies HTTP request body to add `fmfAppRefresh: 2` parameter
- Updates `appVersion`, `buildVersion`, and `osVersion` to iOS 7 values
- Changes `User-Agent` and `X-MMe-Client-Info` headers to iOS 7 format
- Blocks "sign in required" alerts that appear due to session timing issues (workaround)

## Author

Made with ❤️ by Victor Lobe

## License

MIT License – Free to use, share, and modify.
