## App Update Checker

This package is in the API design phase.

To support its development, you can give it a like and a star on [GitHub](https://github.com/StarProxima/dev_kit).

The appcast api under consideration:
```json
{
    "@comment": "Description of the api structure",
    "@commentLink": "https://pub.dev/packages/app_update_checker",
    // Optional, will be set based on the platform and app ID.
    "links": {
        "googlePlay": "https://example.com",
        "appStore": "https://example.com",
        "appGallery": "https://example.com",
        "ruStore": "https://example.com",
        // Custom store
        "gitHub": {
            "link": "https://example.com",
            "platforms": ["android", "windows", "macos", "linux"],
        },
    },
    "releases": [
        {   
            // Required
            "version": "0.3.7",
            // Optional, true by default
            "isActive": true,
            // Optional, false by default
            "isCritical": false,
            // Optional, will be override
            "title": {
                "en": "Version $version is available"
            },
            // Optional, will be override
            "description": {
                "en": "A new version of $appName is available!\nVersion $version is now available. You have a $currentVersion",
            },
            // Optional, may not be displayed
            "releaseNote": {
                "en": "Added bugs, fixed features",
                "es": "Bugs añadidos, correcciones arregladas",
                "ru": "Добавлены баги, устранены фичи"
            },
            // Optional, all by default. Support custom stores
            "stores": ["googlePlay", "appStore", "ruStore"],
            // Optional, from stores by default. Support custom platforms
            "platforms": ["android", "ios", "aurora"]
        }
    ]
}
```