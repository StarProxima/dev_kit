# App Update Checker

![Package Thumbnail](https://github.com/user-attachments/assets/bae1226a-0680-41bf-a4e8-5f08ae483122)

<p align="center">
<a href="https://pub.dev/packages/app_update_checker"><img alt="Pub Version" src="https://img.shields.io/pub/v/app_update_checker"></a>
<a href="https://pub.dev/packages/app_update_checker"><img alt="Pub Points" src="https://img.shields.io/pub/points/app_update_checker"></a>
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
# https://pub.dev/packages/app_update_checker

# Default settings for releases
release_settings:
  # Optional
  title:
    # Any text (title, description, releaseNote)
    # supports optional localization, interpolation and markdown.
    # Also supports short syntax without localization.
    en: |-
      ## New version for ($appName)[https://example.com]
      ### Version $releaseVersion is available!
    es: La versión $releaseVersion está disponible!
    ru: Доступна новая версия!
  # Optional
  description: |-
    A new version of $appName is available!
    Version $releaseVersion is now available. You have a $appVersion
  # Optional, allows users to ignore this specific release until a new one is available
  can_ignore_release: true
  # Interval at which the update notification will be repeatedly shown to the user
  reminder_period_hours: 48
  # Delay that must pass after the release before it begins to be shown to all users
  release_delay_hours: 48
  # Versions prior to this one will receive an obsolescence notice,
  # but may defer the update.
  deprecated_before_version: 0.3.7
  # Versions prior to this one must be updated to the latest version,
  # with no option to defer the update.
  required_minimum_version: 0.1.0 

# Optional, will be set based on the platform and app ID
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
    build_number: 21
    # Optional, active by default
    # May be one of:
    # active - The release is available.
    # inactive - The release is hidden from users.
    # required - The release is required be installed by all users with older versions.
    # deprecated - The release is outdated and is strictly recommended to be updated.
    # broken - The release has critical bugs and requires an update.
    type: active
    # You can also override the title and description here.
    # Optional, may not to be displayed.
    release_note: |-
      # Big update!
      [click](https://example.com) - full changelog.
      ### Short notes
      - Added bugs
      - Fixed features
    # Optional, used to delay the release using releaseDelayHours. Time is optional.
    pub_date_utc: '2024-08-24 15:35:00'
    # Optional, will be override
    can_ignore_release: true
    # Optional, will be override
    reminder_period_hours: 48
    # Optional, will be override
    required_minimum_version: 48
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
    # uses all of its parameters by default.
    ref_version: 0.3.7
    release_note: Minor improvements
    # You can add any custom parameters anywhere in the config, 
    # you can access them from the app using Map.
    is_super_ultra_mega_release: true
    
```


# Shorebird

If you use [Shorebird](https://shorebird.dev/), the Code Push tool for Flutter, this package also allows you to process and show users information about a new patch with release notes with the ability to restart the application.

If you don't need a patch note and a custom title and description, you can omit specific patches from the release. Information about new patches is also provided by shorebird.

```yaml

# Default settings for patches
path_settings:
  # Optional, similar to release title
  title: The new patch is available!
  # Optional, similar to release description
  description: It is needed to fix errors in the app.

releases:
  - version: 1.3.7
    patches:
      - patch_number: 1 # Required
        # Optional, similar to release type
        type: active
        # Optional, you can set the title, description and patchNote.
        title: New patch for $appVersion
        patch_note: Critical fix
        # Optional, uses to refine the version
        build_number: 21

        # Related patch for another platform with different patch number
      - patch_number: 2
        # Optional, reference to another patch by patchNumber,  
        # uses all of its parameters by default
        ref_patch_number: 1
        # Optional, used to reference a patch of a different version
        ref_version: 1.3.7
        # Optional, uses to refine the version
        build_number: 23
    platforms:
      - android
      - ios 
        
```



# Contributors ✨

[![Alt](https://opencollective.com/dev_kit/contributors.svg?width=890&button=false)](https://github.com/remarkablemark/dev_kit/graphs/contributors)

Contributions of any kind welcome!



# Activities

![Alt](https://repobeats.axiom.co/api/embed/732b41cfc45839e3b078304e6b46ca0da7bd7f15.svg "Repobeats analytics image")