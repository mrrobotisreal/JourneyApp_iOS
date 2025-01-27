# My Journey

![Cover Image](https://winapps-solutions-llc.s3.us-west-2.amazonaws.com/products/journey-app/MyJourneyDocumentationCoverImage.png)

### What is "My Journey"?

> _"The perfect companion for your introspective journey, keeping your thoughts organized and your memories accessible at the touch of a finger."_

**My Journey** is a journaling app written entirely in Swift for iOS. It provides users with the ability to create an account, write journal entries with advanced markdown (headings, lists, checkboxes, bold, italic, strikethrough, code, colored text, nested tokens, etc.), images, locations, and tags. The entries all include a date, and can be searched and filtered with optimized search algorithms as well as custom tags created by the user. Users are able to log in on other devices and still maintain access to their data (all data is stored securely on a server and only accessible to the user who created it), and all entries are able to be downloaded to the device for offline viewing and editing. Entries that are created or edited while the user is offline will be stored on the device until a network connection is established again, at which point the data will be sent to the server and stored. When a user has logged in, a session is created and a JSON Web Token is stored on the device which allows the user to remain logged in for a configurable amount of time, but it's defaulted to 7 days and is revoked upon clicking to logout.

## Table of Contents

- [Contact info](#contact-info)
- [Features](#features)
- [Demo](#demo)
- [Getting started](#getting-started)
- [Usage](#usage)
- [Documentation](#documentation)
- [Technologies](#technologies)
- [License](#license)

## Contact info

**Developed by:** Mitchell Wintrow

**Email**: owner@winapps.io, mitchellwintrow@gmail.com

## Features

- 🔒 Secure user authentication
- 🖊️ Advanced markdown parser
- 📸 Add photos or take new photos and add them to your entries
- 📍 Add locations to your entries
- 🏷️ Add custom tags for better organization and optimize search filters
- 🕸️ Sign in and access your data across devices
- 📲 Download entries for offline viewing
- ⬆️ Create entries offline that are uploaded when connection returns

## Demo

**Quick Walkthrough Demo**

![Quick Walkthrough Demo](https://winapps-solutions-llc.s3.us-west-2.amazonaws.com/journey-app/MyJourney_FastDemo.gif)

<!-- ![MyJourneyApp Demo Gif](https://winapps-solutions-llc.s3.us-west-2.amazonaws.com/products/journey-app/MyJourneyApp_Demo.gif) -->

More demos will be added soon... Thanks for your patience!

## Getting Started

Instructions for getting started will be added soon... Thanks for your patience!

## Usage

Instructions for the usage of this app will be added soon... Thanks for your patience!

**Markdown Syntax (In App)**

- Main Heading: `#` at the beginning of a new line
- Subheading: `##` at the beginning of a new line
- Bulleted List Item: `- ` at the beginning of a new line
- Unchecked Checkbox: `- [ ] ` at the beginning of a new line
- Bold Text: `*` wrapped around the text you want to be bold
- Italic Text: `_` wrapped around the text you want to be italicized
- Underline Text: `~` wrapped around the text you want to be underlined
- Strikethrough Text: `-` wrapped around the text you want to be underlined
- Inline Code: `` ` `` wrapped around the code
- Colored Text Example: `{color: red}This text will be red.{color}`
- Nested Tokens Example: `*This is bold and ~underlined~.*`

More markdown syntax customizations coming soon...

## Documentation

You can find the official **My Journey** documentation here:

[Official **MyJourney** Documentation](https://vigorous-helicona-f1e.notion.site/My-Journey-Official-Documentation-18426f695b8e805ab8efc17f6634877d)

## Technologies

**Languages**

![Swift](https://img.shields.io/badge/Swift-F54A2A?logo=swift&logoColor=white)
![Objective-C](https://img.shields.io/badge/Objective--C-%233A95E3.svg?&logo=apple&logoColor=white)
![Go](https://img.shields.io/badge/Go-%2300ADD8.svg?&logo=go&logoColor=white)
![Markdown](https://img.shields.io/badge/Markdown-%23000000.svg?logo=markdown&logoColor=white)

**OS Platforms**

![iOS](https://img.shields.io/badge/iOS-000000?&logo=apple&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-000000?logo=apple&logoColor=F0F0F0)

**IDEs & Text Editors**

![Xcode](https://img.shields.io/badge/Xcode-007ACC?logo=Xcode&logoColor=white)
![Neovim](https://img.shields.io/badge/Neovim-57A143?logo=neovim&logoColor=fff)

**Design**

![Canva](https://img.shields.io/badge/Canva-%2300C4CC.svg?&logo=Canva&logoColor=white)

**Documentation**

![Notion](https://img.shields.io/badge/Notion-000?logo=notion&logoColor=fff)

**Version Control**

![Git](https://img.shields.io/badge/Git-F05032?logo=git&logoColor=fff)

**Producer & Developer**

![WinApps Solutions LLC](https://img.shields.io/badge/WinApps-Solutions-%232f56a0?labelColor=%232f56a0&color=%23ff6f00)
![Mitchell Wintrow](https://img.shields.io/badge/Wintrow-Mitchell?style=flat&label=Mitchell&labelColor=%232f56a0&color=%23ff6f00)

## License

This project is licensed under the **Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License**.

- You can view and share this code for **non-commercial purposes** as long as proper credit is given.
- **Forking, modifications, or derivative works are not allowed.**

For the full license text, visit [Creative Commons License](https://creativecommons.org/licenses/by-nc-nd/4.0/legalcode).

---

This product is developed and owned by [WinApps Solutions LLC ©2024](https://winapps.io)

![WinApps Logo](./WinAppsLogo.svg)
