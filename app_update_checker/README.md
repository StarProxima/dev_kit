## App Update Checker

![App Checker Thumbnail](https://github.com/user-attachments/assets/11e46aea-8451-44e8-88c9-495bbefe18a4)

> [!IMPORTANT]
> This package is in the early API design phase.

---

To support its development, you can give it a like and a star on [GitHub](https://github.com/StarProxima/dev_kit).

The config api structure under consideration:
```yaml
# Description of the api structure
# https://pub.dev/packages/app_update_checker


# Versions prior to this one will receive an obsolescence notice, but may defer the update.
deprecatedBeforeVersion: 0.3.7
# Versions prior to this one must be updated to the latest version, with no option to defer the update.
requiredMinimumVersion: 0.1.0 

# Optional, will be set based on the platform and app ID.
links:
  googlePlay: 'https://example.com'
  appStore: 'https://example.com'
  appGallery: 'https://example.com'
  ruStore: # You can set it like this
    url: 'https://example.com'
  # Custom store
  gitHub:
    url: 'https://example.com'
    platforms:
      - android
      - windows
      - macos
      - linux
releases:
  - version: 0.3.7 # Required
    # Optional, should use the update
    isActive: true 
    # Optional, the update is mandatory for installation by all with a lesser version
    isRequired: false 
    # Optional, if true - becomes inactive, will be required to upgrade to any higher version
    isBroken: false
    # Optional, will be override
    title: 
      en: Version $version is available
    # Optional, will be override
    description: 
      en: |-
        A new version of $appName is available!
        Version $version is now available. You have a $currentVersion
    # Optional, may not be displayed
    releaseNote: 
      en: 'Added bugs, fixed features'
      es: 'Bugs añadidos, correcciones arregladas'
      ru: 'Добавлены баги, устранены фичи'
    # Optional, all by default. Support custom stores
    stores:
      - googlePlay
      - appStore
      - ruStore
      - store: github
        platforms: 
          - android
          - ios
          - aurora
```

## Contributors ✨

[![Alt](https://opencollective.com/dev_kit/contributors.svg?width=890&button=false)](https://github.com/remarkablemark/dev_kit/graphs/contributors)

Contributions of any kind welcome!

## Activities

![Alt](https://repobeats.axiom.co/api/embed/732b41cfc45839e3b078304e6b46ca0da7bd7f15.svg "Repobeats analytics image")