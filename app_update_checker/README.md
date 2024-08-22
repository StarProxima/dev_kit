## App Update Checker

This package is in the API design phase.

To support its development, you can give it a like and a star on [GitHub](https://github.com/StarProxima/dev_kit).

The appcast api under consideration:
```yaml
# Description of the api structure
# https://pub.dev/packages/app_update_checker


# Versions up to this one will receive a deprecation notice but can postpone the update.
deprecationNoticeUntilVersion: 0.1.0 
# Versions up to this one must update to the latest version, with no option to postpone.
requiredUpdateUntilVersion: 0.3.7 

# Optional, will be set based on the platform and app ID.
links:
  googlePlay: 
    url: 'https://example.com'
  appStore: 
    url: 'https://example.com'
  appGallery: 
    url: 'https://example.com'
  ruStore: 
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
    isActive: true # Optional, true by default
    isCritical: false # Optional, false by default
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
    storesV2:
      - store: googlePlay
      - store: appStore
      - store: ruStore
      - store: github
         # Optional, from stores by default. Support custom platforms
        platforms: 
          - android
          - ios
          - aurora
   
    
```
