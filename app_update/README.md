# App Update

![package_thumbnail](https://github.com/user-attachments/assets/e64a441f-6650-4a23-9204-3c61a7a8f2a7)

<p align="center">
<a href="https://pub.dev/packages/app_update"><img alt="Pub Version" src="https://img.shields.io/pub/v/app_update"></a>
<a href="https://pub.dev/packages/app_update"><img alt="Pub Points" src="https://img.shields.io/pub/points/app_update"></a>
<a href="https://github.com/StarProxima/dev_kit"><img src="https://img.shields.io/github/stars/StarProxima/dev_kit?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>
</p>

> [!IMPORTANT]
> This package is in the early API design phase.

---

### Work in progress 🏗️

To support its development, you can give it a like and a star on [GitHub](https://github.com/StarProxima/dev_kit).

---



# Overview

This package is designed to help handle updates to your application in a more flexible way.

It should also help fix problems and get around some annoying limitations of the [Upgrader](https://pub.dev/packages/upgrader) package.

You can show anything you want - a customizable dialog, a modal sheet or a small card to motivate or compel users to update your app. 

The package also supports features such as deprecation for older versions, required updates and rolling back updates.



# Setup methods

There are 2 methods to get information about updates: 
1) From the stores where the app is available 
2) From your own update config, which can be hosted, for example, on your public github repository.

The first method is easier to use, but is not flexible and does not support many features.

The second method requires some customization, but works on all platforms, with all stores, and allows for full control and customization of your update process.

We want to support both methods, but for now we're focusing on the second method.

## Update Config

Here is the full config api structure under consideration:
```yaml
# Description of the api structure
# https://pub.dev/packages/app_update

# Optianal, default settings for releases
release_settings:
  title:
    # Any text (title, description, releaseNotes)
    # supports optional localization, interpolation and markdown.
    # Also supports short syntax without localization.
    en: |-
      ## New version for ($appName)[https://example.com]
      ### Version $releaseVersion is available!
    es: La versión $releaseVersion está disponible!
    ru: Доступна новая версия!

  description: |-
    A new version of $appName is available!
    Version $releaseVersion is now available. You have a $appVersion

  # Allows users to skip this specific release until a new one is available
  can_skip_release: true
  # Allows users to postpone this specific release to a reminder_period_hours
  can_postpone_release: true
  # Interval at which the update notification will be repeatedly shown to the user
  reminder_period_hours: 48
  # Delay that must pass after the release before it begins to be shown to all users
  release_delay_hours: 48
  # Duration over which the release visibility will gradually increase from 0% to 100% of users.
  progressive_rollout_hours: 48

unsupported_versions: ['<=4.2.0', 0.3.4]
deprecated_versions: ['<=5.1.0 >=4.2.0', '>5.6.0 <5.6.7']

# Optional, will be set based on the platform and app ID
sources:
  - name: googlePlay 
    url: https://example.com
  - name: appStore
    url: https://example.com
  - name: appGallery 
    url: https://example.com
    # You can also override any params for this source (title, release_delay_hours, deprecated_versions etc.)
    title: Title
  - name: ruStore 
    url: https://example.com
    # Custom store
  - name: gitHub
    url: https://example.com
    platforms:
      - android
      - windows
      - macos
      - linux

releases:
  - version: 0.3.7 # Required
    # You can also override all release_settings params here (title, release_delay_hours etc.)
    # Optional, may not to be displayed.
    release_notes: |-
      # Big update!
      [click](https://example.com) - full changelog.
      ### Short notes
      - Added bugs
      - Fixed features
    # Optional. Time is also optional.
    date: '2024-08-24 15:35:00Z'
    # Required. Support custom stores
    sources:
        # Supports short syntax
      - googlePlay
      - appStore
      - ruStore
        # Also supports full syntax if you need to override parametrs
      - name: github
        # Override source params
        url: https://example.com
        platforms: [android, windows]
        # And override any release params
        release_notes: Notes
        title: Title
    
  - version: 0.3.8
    release_notes: Minor improvements
    # You can add any custom parameters anywhere in the config, 
    # you can access them from the app using Map.
    is_super_ultra_mega_release: true
    
```


# Shorebird

If you use [Shorebird](https://shorebird.dev/), the Code Push tool for Flutter, this package also allows you to process and show users information about a new patch with the ability to restart the application.

Information about new patches is provided by shorebird.

### Roadmap
✅ Support the release status (required, broken, etc.) 
✅ Finding the latest release woth optimal statis
✅ Custom stores and platform
✅ Link releases to release settings and stores
✅ Parser for UpdateConfig
🏗️ Implement UpdateConfigProvider
🏗️ Provide UpdateController
🏗️ Support reminder period
🏗️ Support delayed release
🏗️ Getting release data directly from the stores
🏗️ Release reference to another releases
🏗️ Specifying texts for different languages
🏗️ Provide UpdateAlert widget
🏗️ Provide UpdateAlertHandler methods
🔳 Provide UpdateAlertCard widget
🔳 Support for markdown in texts
🔳 Specifying texts for specific statuses
🔳 Release progressively rolls
🔳 Package for shorebird patch support 🚀


# Contributors ✨

[![Alt](https://opencollective.com/dev_kit/contributors.svg?width=890&button=false)](https://github.com/remarkablemark/dev_kit/graphs/contributors)

Contributions of any kind welcome!



# Activities

![Alt](https://repobeats.axiom.co/api/embed/732b41cfc45839e3b078304e6b46ca0da7bd7f15.svg "Repobeats analytics image")