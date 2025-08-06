# App Update API v3 Documentation

## Overview

App Update provides a comprehensive configuration system for managing application updates across multiple platforms and stores. The API supports flexible content rules, version lifecycle management, progressive rollouts, and multi-source distribution.

## Configuration Structure

The configuration consists of four main sections:

```yaml
content_rules:        # UI content rules for different contexts
settings_rules:       # Behavioral settings and user actions
app_status_rules:  # Version lifecycle and status management
sources:        # Distribution sources (stores, platforms)
releases:       # Specific release definitions
```

---

## Content Rules

Define UI content based on context, locale, and app status.

### Basic Structure

```yaml
content_rules:
  - view_target: card|dialog|screen|toast|profile_badge|about_screen|any
    app_statuses: active|updateable|outdated|deprecated|unsupported|any
    locales: ru|en|any
    data:
      title: "Update Available"
      description: "New version with improvements"
```

### Parameters

- **`view_target`**: Where the update UI appears
  - `card` - Card-style notification
  - `dialog` - Modal dialog
  - `screen` - Full-screen update prompt
  - `toast` - Brief notification
  - `profile_badge` - Badge in user profile
  - `about_screen` - About/settings screen
  - `any` - any contexts

- **`app_status`**: Application version status
  - `active` - Current/latest version
  - `updateable` - Update available but optional
  - `outdated` - Should update soon
  - `deprecated` - Must update soon
  - `unsupported` - Forced update required

- **`locale`**: Language/region targeting
- **`data`**: Content payload with custom fields support

---

## Settings Rules

Control update behavior, user actions, and timing.

### Basic Structure

```yaml
settings_rules:
  - app_statuses: any
    view_target: any
    data:
      should_show: true|false
      can_skip: true|false
      can_postpone: true|false
      skip_release_delay_hours: 2160    # 90 days
      skip_any_releases_delay_hours: 72  # 3 days
      postpone_release_delay_hours: 96   # 4 days
      postpone_any_releases_delay_hours: 24  # 1 day
```

### Key Settings

- **`should_show`**: Whether to display update prompt
- **`can_skip`**: anyow users to skip this update
- **`can_postpone`**: anyow users to postpone update
- **`*_delay_hours`**: Cooldown periods for user actions

### Recommended Status Configurations

```yaml
# Unsupported - Force update
- app_statuses: unsupported
  data:
    can_skip: false
    can_postpone: false

# Deprecated - anyow postpone but encourage update
- app_statuses: deprecated
  data:
    can_postpone: true
    postpone_release_delay_hours: 24

# Optional updates - Full user control
- app_statuses: [outdated, updateable, active]
  data:
    can_skip: true
    can_postpone: true
```

---

## Version Rules

Define version lifecycle with progressive rollouts and time-based transitions.

### Basic Structure

```yaml
app_status_rules:
  - version: ">=6.0.0"           # Semver constraint
    date: "2024-10-17 23:00:00"  # Activation date
    app_statuses: active
    release_status: available|discontinued
    
  - version: "<=1.0.0"
    app_statuses: unsupported
    release_status: discontinued
```

### Progressive Rollout

```yaml
app_status_rules:
  - version: "<=3.0.0"
    date: "2024-10-17"
    rollout:
      - delay_hours: 12              # Wait 12h before starting
        rollout_hours: 72            # Roll out over 72h
        segmentation_percent: 10     # Affect 10% of users
        app_statuses: deprecated
        
      - delay_hours: 168            # After 7 days
        rollout_hours: 336          # Roll out over 14 days
        segmentation_percent: 100   # Affect any users
        app_statuses: unsupported
```

### Dynamic Date References

```yaml
app_status_rules:
  # Use app release date as reference
  - version: any
    date: localReleaseDate    # Date from current app version
    rollout:
      - delay_hours: 168
        app_statuses: outdated
        
  # Use latest update release date
  - version: any
    date: updateReleaseDate  # Date from latest available update
    rollout:
      - delay_hours: 48
        app_statuses: outdated
```

### Version Constraint Examples

```yaml
app_status_rules:
  - version: "<=1.0.0"                    # Single constraint
  - version: ">3.0.0 <4.0.0"            # Range constraint
  - version: ["<=5.1.0 >=4.2.0", ">5.6.0 <5.6.7"]  # Multiple constraints
  - version: any                          # Match any versions
```

---

## Sources

Define distribution sources with platform-specific configurations.

### Basic Structure

```yaml
sources:
  - name: googlePlay
    url: "https://play.google.com/store/apps/details?id=com.example"
    platforms: [android]
    
  - name: appStore  
    url: "https://apps.apple.com/app/id123456789"
    platforms: [ios, macos]
```

### Platform-Specific Overrides

```yaml
sources:
  - name: github
    url: "https://github.com/user/repo/releases"
    platforms:
      # Full platform configuration
      - name: android
        source:
          url: "https://github.com/user/repo/releases/download/v1.0/app.apk"
          content_rules:
            title: "Download APK"
      
      # Simple platform list
      - windows
      - macos
      - linux
```

### Source Content Override

```yaml
sources:
  - name: ruStore
    url: "https://apps.rustore.ru/app/com.example"
    content_rules:
      title: "Обновить в RuStore"  # Source-specific content
```

---

## Releases

Define specific application releases with version, date, and source information.

### Basic Structure

```yaml
releases:
  - version: "1.2.0"
    date: "2024-08-24 15:35:00"    # Local time
    content_rules:
      title: "Major Update"
      description: "New features and improvements"
      release_notes: |
        # What's New
        - Feature A
        - Bug fixes
    sources:
      - googlePlay
      - appStore
```

### Time Zone Handling

```yaml
releases:
  - version: "1.0.0"
    date: "2024-10-17 23:00:00"    # Local time
    
  - version: "1.0.1" 
    date: "2024-10-17 23:00:00Z"   # UTC time (note the Z suffix)
```

### Source-Specific Releases

```yaml
releases:
  - version: "1.2.0"
    sources:
      - appStore
      - name: googlePlay
        date: "2024-10-18 10:00:00"  # Different release date
        
      - name: ruStore
        url: "https://custom-url.com"
        platforms: [android]
        release:
          version: "1.2.1"           # Different version number
          content_rules:
            title: "RuStore Exclusive"
```

### Nested Platform Overrides

```yaml
releases:
  - version: "1.0.0"
    sources:
      - name: github
        platforms:
          - name: windows
            source:
              url: "https://github.com/user/repo/releases/download/v1.0/app-windows.zip"
              release:
                content_rules:
                  - locales: ru
                    data:
                      release_notes: "Заметки для Windows версии"
                settings_rules:
                  can_postpone: true
```

### Custom Data Support

```yaml
releases:
  - version: "0.3.8+10-beta"
    sources: []
    is_super_ultra_mega_release: true    # Custom fields preserved
    custom_metadata:
      priority: high
      feature_flags: ["new_ui", "beta_features"]
```

---

## Advanced Features

### Rule Priority and Merging

Rules are applied in order with later rules taking priority:

1. **Content Rules**: Multiple rules can apply, with later rules overriding specific fields
2. **Settings Rules**: Merged hierarchicanyy with specific rules overriding general ones
3. **Version Rules**: First matching rule applies (except in rollout scenarios)

### Localization Support

```yaml
content_rules:
  - locales: ru
    data:
      title: "Обновление доступно"
      description: "Новая версия с улучшениями"
      
  - locales: en  
    data:
      title: "Update Available"
      description: "New version with improvements"
```

### Progressive Rollout Strategy

```yaml
app_status_rules:
  - version: ">=2.0.0"
    rollout:
      # Phase 1: 10% of users after 1 day
      - delay_hours: 24
        rollout_hours: 48
        segmentation_percent: 10
        app_statuses: updateable
        
      # Phase 2: 50% of users after 3 days  
      - delay_hours: 72
        rollout_hours: 72
        segmentation_percent: 50
        app_statuses: outdated
        
      # Phase 3: any users after 1 week
      - delay_hours: 168
        rollout_hours: 24
        segmentation_percent: 100
        app_statuses: deprecated
```

---

## Best Practices

### 1. Version Lifecycle Management

```yaml
app_status_rules:
  # Block very old versions
  - version: "<=1.0.0"
    app_statuses: unsupported
    release_status: discontinued
    
  # Gradual deprecation for older versions
  - version: any
    date: localReleaseDate
    rollout:
      - delay_hours: 2160    # 90 days: outdated
        app_statuses: outdated
      - delay_hours: 4320    # 180 days: deprecated  
        app_statuses: deprecated
      - delay_hours: 6480    # 270 days: unsupported
        app_statuses: unsupported
```

### 2. User Experience Optimization

```yaml
settings_rules:
  # Default: don't show unless explicitly enabled
  - app_statuses: any
    data:
      should_show: false
      
  # Progressive urgency
  - app_statuses: updateable
    data:
      should_show: true
      can_skip: true
      can_postpone: true
      
  - app_statuses: deprecated
    data:
      should_show: true
      can_skip: false
      can_postpone: true
      postpone_release_delay_hours: 24
      
  - app_statuses: unsupported
    data:
      should_show: true
      can_skip: false
      can_postpone: false
```

### 3. Multi-Platform Distribution

```yaml
sources:
  - name: primary_store
    platforms: [android, ios]
    url: "https://primary-store.com"
    
  - name: secondary_store
    platforms: [android]
    url: "https://secondary-store.com"
    content_rules:
      title: "Also available on Secondary Store"
      
  - name: direct_download
    platforms: [windows, macos, linux]
    url: "https://example.com/download"
```

---

## Migration and Compatibility

When upgrading to API v3:

1. **Content Rules**: Replace static content with rule-based system
2. **Settings**: Migrate boolean flags to time-based delay system  
3. **Version Management**: Convert simple version checks to constraint-based rules
4. **Sources**: Restructure platform-specific URLs using nested configuration

The API maintains backward compatibility for basic configurations while providing advanced features through the new rule system.