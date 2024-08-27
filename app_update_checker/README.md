## App Update Checker

![Package Thumbnail](https://github.com/user-attachments/assets/bae1226a-0680-41bf-a4e8-5f08ae483122)

> [!IMPORTANT]
> This package is in the early API design phase.

---

#### Work in progress 🏗️

To support its development, you can give it a like and a star on [GitHub](https://github.com/StarProxima/dev_kit).

---



## Overview

This package is designed to help handle updates to your application in a more flexible way.

It should also help fix problems and get around some annoying limitations of the [Upgrader](https://pub.dev/packages/upgrader) package.

You can show anything you want - a customizable dialog, a modal sheet or a small card to motivate or compel users to update your app. 

The package also supports features such as deprecation for older versions, required updates and rolling back updates.



## Setup methods

There are 2 methods to get information about updates: 
1) From the stores where the app is available 
2) From your own update config, which can be hosted, for example, on your public github repository.

The first method is easier to use, but is not flexible and does not support many features.

The second method requires some customization, but works on all platforms, with all stores, and allows for full control and customization of your update process.

We want to support both methods, but for now we're focusing on the second method.

### Update Config

Here is the full config api structure under consideration:
```yaml
# Description of the api structure
# https://pub.dev/packages/app_update_checker

# Default settings for releases
releaseSettings:
  # Optional
  title: 
    en: Version $releaseVersion is available
  # Optional
  description: 
    en: |-
      A new version of $appName is available!
      Version $releaseVersion is now available. You have a $appVersion
  # Interval at which the update notification will be repeatedly shown to the user.
  reminderPeriodHours: 48
  # Delay that must pass after the release before it begins to be shown to all users.
  releaseDelayHours: 48
  # Versions prior to this one will receive an obsolescence notice,
  # but may defer the update.
  deprecatedBeforeVersion: 0.3.7
  # Versions prior to this one must be updated to the latest version,
  # with no option to defer the update.
  requiredMinimumVersion: 0.1.0 

# Optional, will be set based on the platform and app ID.
stores:
  - name: googlePlay 
    url: https://example.com
  - name: appStore
    url: https://example.com
  - name: appGallery 
    url: https://example.com
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
    # Optional, uses to refine the version
    buildNumber: 21 
    # Optional, should use the update
    isActive: true 
    # Optional, the update is mandatory for installation by all with a lesser version
    isRequired: false 
    # Optional, if true - becomes inactive,
    # will be required to upgrade to any higher version
    isBroken: false
    # Optional, will be override
    title: 
      en: Version $releaseVersion is available
    # Optional, will be override
    description: 
      en: |-
        A new version of $appName is available!
        Version $releaseVersion is now available. You have a $appVersion
    # Optional, may not be displayed
    releaseNote: 
      en: 'Added bugs, fixed features'
      es: 'Bugs añadidos, correcciones arregladas'
      ru: 'Добавлены баги, устранены фичи'
    # Optional, used to delay the release using releaseDelayHours
    pubDateUtc: '2024-08-24 15:35:00',
    # Optional, will be override
    reminderPeriodHours: 48,
    # Optional, will be override
    releaseDelayHours: 48,
    # Optional, all by default. Support custom stores
    stores:
        # Supports short syntax
      - googlePlay
      - appStore
      - ruStore
        # Also supports full syntax if you need to override parametrs
      - name: github
        url: https://example.com
        platforms: 
          - android
          - ios
          - aurora
    
  - version: 0.3.8
    # Reference to another release by version,
    # uses all of its parameters by default
    ref: 0.3.7
    # Аlso supports short syntax without localization
    releaseNote: Minor improvements
    
```



## Shorebird

If you use [Shorebird](https://shorebird.dev/), the Code Push tool for Flutter, this package also allows you to process and show users information about a new patch with release notes with the ability to restart the application.

```yaml

releases:
  - version: 1.3.7
    patches:
      - patchNumber: 1 # Required
        # Optional, should use the patch
        isActive: true 
        # Optional, the patch is mandatory for installation by all before using the app
        isRequired: false 
        # Optional, if true - becomes inactive, 
        # will be required to upgrade to any higher patch
        isBroken: false
        # Optional, you can set the title, description and patchNote
        patchNote: 
          en: 'Critical fix'
        # Optional, uses to refine the version
        buildNumber: 21

        # Related patch for another platform with different patch number
      - patchNumber: 2
        # Reference to another patch by patchNumber,  
        # uses all of its parameters by default
        ref: 1
        buildNumber: 23
    platforms:
      - android
      - ios 
        
```



## Contributors ✨

[![Alt](https://opencollective.com/dev_kit/contributors.svg?width=890&button=false)](https://github.com/remarkablemark/dev_kit/graphs/contributors)

Contributions of any kind welcome!



## Activities

![Alt](https://repobeats.axiom.co/api/embed/732b41cfc45839e3b078304e6b46ca0da7bd7f15.svg "Repobeats analytics image")