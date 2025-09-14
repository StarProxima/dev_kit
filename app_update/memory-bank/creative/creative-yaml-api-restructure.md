# Creative Phase: YAML API Restructuring

## 🎯 CREATIVE PHASE: ARCHITECTURE DESIGN

### Problem Statement
Реструктуризация YAML правил API для улучшения читаемости, концептуальной ясности и developer experience.

**Current Issues:**
- Flat structure смешивает matching conditions с rollout parameters
- custom_params имеет dual purpose (matching + data storage)
- Large rules становятся нечитаемыми
- Cognitive load для понимания field purposes

### Requirements Analysis
**Functional:**
- Четкое разделение matching logic от temporal logic
- Intuitive naming conventions
- Support для simple rules без verbose syntax
- Preserved functionality parity

**Non-Functional:**
- Zero performance regression
- Type safety preservation  
- Improved developer experience
- Future extensibility

### Architecture Options Evaluated

#### Option 1: when/rollout/data ⭐ SELECTED
```yaml
content:
  - when:      # 🎯 Matching conditions
      view_target_is: card
      locale_is: ru
    rollout:   # ⏰ Temporal parameters
      date: $updateReleaseDate
      delay_hours: 24
    data:      # 📄 Rule output
      title: "Обновление"
```

**Selection Rationale:**
- Crystal clear semantic separation
- Future extensibility для new sections
- Professional enterprise-grade structure
- Eliminates custom_params ambiguity

#### Option 2: conditions/actions/data (Rejected)
**Rejection Reason:** "actions" terminology misleading для temporal parameters

#### Option 3: match/schedule/output (Rejected)  
**Rejection Reason:** Requires too many new field names, adds parser complexity

### 🏗️ FINAL ARCHITECTURE DESIGN

#### New Model Hierarchy
```dart
class UpdateRuleConfig<T extends Mergeable<T>> {
  final UpdateRuleWhen? when;       // ← Matching conditions
  final UpdateRuleRollout? rollout; // ← Temporal parameters
  final T data;                     // ← Rule result data
}

class UpdateRuleWhen {
  final List<AppStatus>? appStatusIs;
  final List<UpdateLocale>? localeIs;
  final List<UpdateViewTarget>? viewTargetIs;
  final List<UpdateVersionConstraint>? appVersionIs;
  final List<UpdateSource>? sourceIs;
  final List<UpdatePlatform>? platformIs;
  final Map<String, dynamic>? customParams;  // ← Only matching params
}

class UpdateRuleRollout {
  final UpdateDate? date;
  final Duration? delay;
  final Duration? rollout;
  final double? userSegmentationPercent;
}
```

#### Parser Architecture  
```dart
class UpdateRuleConfigParser {
  static const _whenParser = UpdateRuleWhenParser();
  static const _rolloutParser = UpdateRuleRolloutParser();
  
  UpdateRuleConfig<T>? parse<T extends Mergeable<T>>(...) {
    final whenValue = map.remove('when');
    final rolloutValue = map.remove('rollout');
    final dataValue = map.remove('data');
    
    return UpdateRuleConfig<T>(
      when: _whenParser.parse(whenValue, isDebug: isDebug),
      rollout: _rolloutParser.parse(rolloutValue, isDebug: isDebug),
      data: dataParser(dataValue),
    );
  }
}
```

#### Compatibility Strategy
```dart
// Convenience accessors для seamless migration:
class UpdateRuleConfig<T extends Mergeable<T>> {
  // Direct access to nested fields:
  List<AppStatus>? get appStatusIs => when?.appStatusIs;
  UpdateDate? get date => rollout?.date;
  Duration? get delay => rollout?.delay;
  // ... all current fields accessible
}
```

### Implementation Guidelines

#### Phase 1: Models (1-2 дня)
1. Create UpdateRuleWhen и UpdateRuleRollout classes
2. Refactor UpdateRuleConfig с composition
3. Add convenience accessors for compatibility
4. Update copyWith methods

#### Phase 2: Parsers (2-3 дня)  
1. Create UpdateRuleWhenParser
2. Create UpdateRuleRolloutParser
3. Rewrite UpdateRuleConfigParser for new structure
4. Maintain error quality и validation

#### Phase 3: Integration (1-2 дня)
1. Test all matchers work via accessors
2. Update default rules с new constructors
3. Validate resolver system compatibility
4. Performance verification

#### Phase 4: Testing (3-4 дня)
1. Update all test helpers (createTestRule, etc.)
2. Migrate test YAML fixtures
3. Add new structure specific tests
4. Validate 95%+ coverage maintenance

#### Phase 5: Documentation (2-3 дня)
1. Update API documentation с new examples
2. Update Memory Bank docs (parser.md, resolver.md)
3. Update all YAML examples
4. Create conversion reference guide

### Validation Criteria
- **[✓] Problem solved**: Clear conceptual separation achieved
- **[✓] Requirements met**: All functional и non-functional requirements satisfied
- **[✓] Technical feasibility**: Implementation path clear и achievable
- **[✓] Risk mitigation**: Convenience accessors ensure compatibility
- **[✓] Future extensibility**: Architecture supports growth

## 🎯 Expected Outcomes

### Developer Experience Improvements
```yaml
# Before (confusing):
content:
  - view_target_is: card
    app_status_is: any
    date: 2020-01-01
    delay_hours: 24
    custom_params:
      env_is: prod        # ← Matching  
    data:
      title: "Title"
      analytics: data     # ← Data storage (confusing!)

# After (crystal clear):
content:
  - when:
      view_target_is: card
      app_status_is: any
      custom_params:
        env_is: prod      # ← Obviously для matching
    rollout:
      date: 2020-01-01
      delay_hours: 24     # ← Obviously для timing
    data:
      title: "Title"
      custom_params:
        analytics: data   # ← Obviously для data storage
```

### Architecture Benefits
1. **Conceptual Clarity** - each section has obvious purpose
2. **Maintainability** - easier to understand и modify large configs
3. **Extensibility** - future sections (monitoring, analytics) fit naturally
4. **Professional Quality** - enterprise-grade configuration management

**Creative Phase Complete - Ready for Implementation**
