# Task: YAML Rule Structure Redesign для App Update Library

## Описание задачи
Реструктуризация YAML API для правил с целью улучшения читаемости и логической группировки полей. Переход от flat structure к nested structure с группировкой по назначению.

## Сложность
**Level: 3** (Intermediate Feature)
**Type**: API Breaking Change + Architecture Enhancement
**Scope**: Multiple subsystems (Models, Parser, Resolver, Tests, Documentation)

## Текущая проблема
```yaml
# Текущая структура - все поля на одном уровне:
content:
  - view_target_is: card          # Условие
    app_status_is: any            # Условие  
    locale_is: any                # Условие
    date: 2020-01-01              # Rollout параметр
    delay_hours: 24               # Rollout параметр
    rollout_hours: 72             # Rollout параметр
    segmentation_percent: 10      # Rollout параметр
    custom_params:                # Смешанное назначение
      env_is: prod                # Условие
      analytics_data: value       # Data
    data:                         # Данные правила
      title: "Обновите приложение"
```

**Проблемы текущего подхода:**
1. **Смешение концепций** - условия и rollout параметры на одном уровне
2. **Неинтуитивность** - сложно понять назначение полей
3. **Verbose custom_params** - dual purpose затрудняет понимание
4. **Сложность чтения** - большие правила выглядят как "плоский список"

## Предлагаемое решение
```yaml
# Новая структура - логическая группировка:
content:
  - when:                         # 🎯 Условия матчинга
      view_target_is: card
      app_status_is: any
      locale_is: any
      custom_params:
        env_is: prod
    rollout:                      # ⏰ Temporal параметры
      date: 2020-01-01
      delay_hours: 24
      rollout_hours: 72
      segmentation_percent: 10
    data:                         # 📄 Данные правила
      title: "Обновите приложение"
      custom_params:
        analytics_data: value
```

## Анализ альтернативных структур

### Вариант 1: when/rollout/data (предложенный)
```yaml
content:
  - when: { conditions }
    rollout: { temporal_params }
    data: { rule_data }
```

**Плюсы:**
- ✅ Четкое разделение концепций
- ✅ Интуитивные названия секций
- ✅ Separates matching logic от rollout logic

**Минусы:**
- ❌ Breaking change (все существующие конфиги)
- ❌ Более verbose для простых правил
- ❌ custom_params дублируется (в when и data)

### Вариант 2: conditions/timing/content
```yaml
content:
  - conditions:
      view_target_is: card
      app_status_is: any
    timing:
      date: 2020-01-01
      delay_hours: 24
    content:
      title: "Title"
```

**Плюсы:**
- ✅ Очень explicit названия
- ✅ content секция более natural

**Минусы:**
- ❌ content/content naming conflict
- ❌ timing не покрывает segmentation

### Вариант 3: match/schedule/output
```yaml
content:
  - match:
      target: card
      status: any
      locale: any
    schedule:
      from: 2020-01-01
      delay: 24h
      rollout: 72h
      percent: 10
    output:
      title: "Title"
```

**Плюсы:**
- ✅ Краткие field names
- ✅ Human-readable time formats
- ✅ Уникальные названия секций

**Минусы:**
- ❌ Требует новые field names (больше breaking changes)
- ❌ Менее explicit чем when/rollout/data

### Вариант 4: Гибридный подход (backward compatible)
```yaml
content:
  # Новый синтаксис:
  - when: { view_target_is: card }
    rollout: { date: 2020-01-01 }
    data: { title: "Title" }
    
  # Старый синтаксис (still supported):
  - view_target_is: card
    date: 2020-01-01
    data: { title: "Title" }
```

**Плюсы:**
- ✅ Backward compatibility
- ✅ Gradual migration path
- ✅ Flexibility для different use cases

**Минусы:**
- ❌ Code complexity (dual parsing logic)
- ❌ Потенциальная confusion (два способа писать одно)

## Рекомендация: Вариант 1 с улучшениями

### Optimized Variant 1: when/rollout/data
```yaml
content:
  # Простое правило - minimal syntax:
  - when: { locale_is: ru }
    data: { title: "Русский заголовок" }
    
  # Средней сложности:
  - when:
      view_target_is: card
      app_status_is: outdated
    data:
      title: "Update Available"
      
  # Комплексное правило - full syntax:
  - when:
      view_target_is: [card, dialog]
      app_status_is: [outdated, deprecated]
      locale_is: ru
      custom_params:
        env_is: prod
        user_tier_is: premium
    rollout:
      date: $updateReleaseDate
      delay_hours: 24
      rollout_hours: 168
      segmentation_percent: 25
    data:
      title: "Премиум обновление"
      description: "Эксклюзивные функции доступны"
      custom_params:
        analytics_track: "premium_rollout"
        ui_variant: "gold_theme"
```

## Компоненты требующие изменений

### 1. Core Models (🔥 CRITICAL)
**Файл**: `lib/src/models/update_rule/update_rule_config.dart`
**Изменения**: Fundamental restructure

```dart
// Текущая структура:
class UpdateRuleConfig<T extends Mergeable<T>> {
  final List<AppStatus>? appStatusIs;     // ← Переместить в when
  final List<UpdateLocale>? localeIs;     // ← Переместить в when
  final UpdateDate? date;                 // ← Переместить в rollout
  final Duration? delay;                  // ← Переместить в rollout
  final T data;                           // ← Остается
}

// Новая структура:
class UpdateRuleConfig<T extends Mergeable<T>> {
  final UpdateRuleWhen? when;             // ← NEW: grouped conditions
  final UpdateRuleRollout? rollout;       // ← NEW: grouped temporal params
  final T data;                           // ← Unchanged
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
  final double? segmentationPercent;
}
```

### 2. Parser System (🔥 CRITICAL)
**Файл**: `lib/src/parser/sub_parsers/update_rule_config_parser.dart`
**Изменения**: Complete rewrite parsing logic

```dart
// NEW parsers needed:
class UpdateRuleWhenParser {
  UpdateRuleWhen? parse(Object? value, {required bool isDebug}) {
    // Parse all condition fields
  }
}

class UpdateRuleRolloutParser {
  UpdateRuleRollout? parse(Object? value, {required bool isDebug}) {
    // Parse all temporal fields
  }
}

// Modified UpdateRuleConfigParser:
UpdateRuleConfig<T>? parse<T extends Mergeable<T>>(...) {
  // Parse new structure:
  final whenValue = map.remove('when');
  final rolloutValue = map.remove('rollout');
  final dataValue = map.remove('data');
  
  // Fallback logic для backward compatibility?
}
```

### 3. Resolver System (🔥 CRITICAL)
**Файлы**: `lib/src/resolver/matchers/*.dart`
**Изменения**: All matchers need to adapt

```dart
// Current approach:
bool isMatches({
  required UpdateRuleConfig rule,
  required UpdateSearchData search,
}) {
  final ruleStatuses = rule.appStatusIs ?? [AppStatus.any];  // ← Direct access
  // ...
}

// New approach:
bool isMatches({
  required UpdateRuleConfig rule,
  required UpdateSearchData search,
}) {
  final ruleStatuses = rule.when?.appStatusIs ?? [AppStatus.any];  // ← Nested access
  // ...
}
```

### 4. Default Rules (🔥 CRITICAL)
**Файлы**: `lib/src/default_rules/**/*.dart`
**Изменения**: All default rules need restructuring

```dart
// Current:
final defaultEnContentRules = [
  const UpdateRuleConfig(
    localeIs: [UpdateLocale.en, UpdateLocale.any],
    data: UpdateContentConfig.byRequired(/*...*/),
  ),
];

// New:
final defaultEnContentRules = [
  const UpdateRuleConfig(
    when: UpdateRuleWhen(
      localeIs: [UpdateLocale.en, UpdateLocale.any],
    ),
    data: UpdateContentConfig.byRequired(/*...*/),
  ),
];
```

### 5. Test Suite (⚠️ EXTENSIVE)
**Файлы**: `test/**/*rule*test.dart` (53+ файла)
**Изменения**: Complete test rewrite

```dart
// All rule creation helpers need updates:
UpdateRuleConfig<UpdateContentConfig> createTestRule({
  List<UpdateViewTarget> targets = const [UpdateViewTarget.any],
  List<UpdateLocale> locales = const [UpdateLocale.any],
  UpdateDate date = UpdateDate.any,
  Duration? delay,
  String? title,
}) {
  // OLD:
  return UpdateRuleConfig<UpdateContentConfig>.byRequired(
    viewTargetIs: targets,
    localeIs: locales,
    date: date,
    delay: delay,
    data: UpdateContentConfig(title: title),
  );
  
  // NEW:
  return UpdateRuleConfig<UpdateContentConfig>.byRequired(
    when: UpdateRuleWhen(
      viewTargetIs: targets,
      localeIs: locales,
    ),
    rollout: UpdateRuleRollout(
      date: date,
      delay: delay,
    ),
    data: UpdateContentConfig(title: title),
  );
}
```

### 6. Documentation (📝 IMPORTANT)  
**Файлы**: 
- `API_v3_Documentation.md`
- `memory-bank/docs/parser.md`
- `memory-bank/docs/resolver.md`
- YAML examples во всех файлах

**Изменения**: All examples need to be updated

### 7. Example Configurations (📝 IMPORTANT)
**Файлы**:
- `api_v3.yaml`
- `settings_example.yaml`
- `example/config/*.yaml`
- `test/parser/helpers/api_v3.yaml`

## Implementation Strategy

### Phase 1: Model Design (1-2 дня)
1. **Design new model structure**
   - Create UpdateRuleWhen class
   - Create UpdateRuleRollout class  
   - Modify UpdateRuleConfig class
   - Design backward compatibility strategy

2. **Prototype validation**
   - Create sample YAML с new structure
   - Test readability и usability
   - Validate all use cases covered

### Phase 2: Parser Implementation (2-3 дня)
1. **Create new parsers**
   - UpdateRuleWhenParser
   - UpdateRuleRolloutParser
   - Modify UpdateRuleConfigParser

2. **Implement backward compatibility**
   - Support both old и new syntax
   - Migration warnings
   - Graceful fallbacks

### Phase 3: Resolver Adaptation (1-2 дня)
1. **Update all matchers**
   - Change field access paths
   - Maintain same matching logic
   - Test compatibility

2. **Validate temporal logic**
   - Ensure rollout calculations unchanged
   - Test edge cases
   - Performance verification

### Phase 4: Testing Overhaul (3-4 дня)
1. **Update test helpers**
   - Modify createTestRule functions
   - Update YAML fixtures
   - Maintain test coverage

2. **Add new structure tests**
   - Test new parsing logic
   - Test backward compatibility
   - Integration tests

### Phase 5: Documentation Update (1-2 дня)
1. **Update all documentation**
   - API documentation
   - Memory Bank docs
   - Code examples
   - Migration guide

## Dependencies и Risk Assessment

### High-Risk Dependencies
- **All existing user configs** break без backward compatibility
- **Parser system** requires complete rewrite parsing logic
- **Test suite** requires extensive updates (1000+ lines)

### Mitigation Strategies
1. **Backward compatibility period** - support both syntaxes
2. **Migration tooling** - automated conversion utilities
3. **Comprehensive testing** - ensure no regression
4. **Clear migration guide** - step-by-step upgrade path

## Creative Phases Required

### 🎨 API Design Creative Phase
**Component**: YAML structure design
**Decisions needed**:
- Final field grouping structure
- Backward compatibility strategy  
- Migration path design
- Alternative syntax evaluation

### 🏗️ Parser Architecture Creative Phase  
**Component**: Parser restructuring
**Decisions needed**:
- Dual syntax support implementation
- Error handling для mixed syntaxes
- Performance optimization strategy
- Validation logic redesign

## Technology Validation Checkpoints
- [ ] New model structure compiles и functions
- [ ] Parser handles both old/new syntax correctly
- [ ] Resolver logic unchanged functionally
- [ ] All existing tests pass с new structure
- [ ] Performance impact acceptable

## Next Recommended Mode
**CREATIVE MODE** - для design decisions на API structure и implementation approach

## 🔍 DETAILED CODEBASE IMPACT ANALYSIS

### Affected Files Analysis (по результатам grep)

#### 1. Core Model Files (4 файла) - 🔥 CRITICAL CHANGES
- `lib/src/models/update_rule/update_rule_config.dart` - **COMPLETE RESTRUCTURE**
- `lib/src/models/update_rule/update_rules_container.dart` - Minimal changes
- `lib/src/utils/mergeable.dart` - Possible additions for new classes
- **NEW FILES NEEDED**: `update_rule_when.dart`, `update_rule_rollout.dart`

#### 2. Parser System (2+ файла) - 🔥 CRITICAL CHANGES  
- `lib/src/parser/sub_parsers/update_rule_config_parser.dart` - **COMPLETE REWRITE**
- `lib/src/parser/base_parsers/update_rules_container_parser.dart` - Adapter changes
- **NEW FILES NEEDED**: `update_rule_when_parser.dart`, `update_rule_rollout_parser.dart`

#### 3. Resolver System (9 файлов) - ⚠️ SIGNIFICANT CHANGES
- `lib/src/resolver/update_rule_resolver.dart` - Minor field access changes
- `lib/src/resolver/matchers/app_status_matcher.dart` - `rule.appStatusIs` → `rule.when?.appStatusIs`
- `lib/src/resolver/matchers/locale_matcher.dart` - `rule.localeIs` → `rule.when?.localeIs`
- `lib/src/resolver/matchers/view_target_matcher.dart` - Field access update
- `lib/src/resolver/matchers/version_matcher.dart` - Field access update
- `lib/src/resolver/matchers/platform_matcher.dart` - Field access update
- `lib/src/resolver/matchers/source_matcher.dart` - Field access update
- `lib/src/resolver/matchers/temporal_matcher.dart` - `rule.date/delay/rollout` → `rule.rollout?.date/delay/rollout`
- `lib/src/resolver/matchers/custom_params_matcher.dart` - `rule.customParams` → `rule.when?.customParams`

#### 4. Default Rules (7 файлов) - ⚠️ MODERATE CHANGES
- `lib/src/default_rules/content/translations/default_en_content_rules.dart`
- `lib/src/default_rules/content/translations/default_ru_content_rules.dart`
- `lib/src/default_rules/settings/default_update_settings_rules.dart`
- `lib/src/default_rules/app_settings/default_update_app_settings.dart`
- `lib/src/default_rules/content/default_source_url_update_content.dart`
- **All need constructor syntax updates**

#### 5. Test System (12+ файлов) - ⚠️ EXTENSIVE CHANGES
- `test/resolver/update_rule_resolver/helpers/resolver_test_helpers.dart` - **createTestRule REWRITE**
- `test/linker/helpers/linker_helper.dart` - **createContentRule REWRITE**
- **All rule-related tests** need helper function updates
- **53+ test files** identified using current syntax

#### 6. Documentation (5+ файлов) - 📝 CONTENT UPDATES
- `API_v3_Documentation.md` - All examples update
- `memory-bank/docs/parser.md` - Examples update
- `memory-bank/docs/resolver.md` - Examples update  
- `api_v3.yaml` - Complete restructure
- `settings_example.yaml` - Examples update

#### 7. Configuration Examples (4+ файла) - 📝 CONTENT UPDATES
- `example/config/*.yaml` - All examples
- `test/parser/helpers/api_v3.yaml` - Test fixture
- Various YAML examples в test files

### Impact Severity Assessment
```
🔥 CRITICAL (Breaking changes): 15+ файлов
⚠️ SIGNIFICANT (Logic changes): 20+ файлов  
📝 CONTENT (Examples/docs): 30+ файлов
📊 TOTAL IMPACT: 65+ файлов
```

## 🔧 ALTERNATIVE STRUCTURE ANALYSIS

### Alternative 1: when/rollout/data (RECOMMENDED)
```yaml
content:
  - when:
      view_target_is: card
      app_status_is: any
    rollout:
      date: 2020-01-01
      delay_hours: 24
      rollout_hours: 72
      segmentation_percent: 10
    data:
      title: "Title"
```

**Pros:**
- ✅ **Clear conceptual separation** - matching vs timing vs content
- ✅ **Intuitive naming** - when/rollout/data are self-explanatory
- ✅ **Eliminates custom_params confusion** - clear where each goes
- ✅ **Future extensibility** - easy to add new sections

**Cons:**
- ❌ **Major breaking change** - all existing configs invalid
- ❌ **Implementation complexity** - 65+ файлов affected
- ❌ **Migration burden** - users need to rewrite configs

### Alternative 2: conditions/timing/data
```yaml
content:
  - conditions:
      view_target_is: card
      app_status_is: any
    timing:
      date: 2020-01-01
      delay_hours: 24
    data:
      title: "Title"
```

**Pros:**
- ✅ **Very explicit naming** - conditions/timing clear
- ✅ **Professional terminology** - enterprise-grade naming

**Cons:**
- ❌ **Verbose names** - longer to type
- ❌ **Same breaking change impact** as Alternative 1

### Alternative 3: Backward Compatible Hybrid
```yaml
content:
  # NEW syntax (preferred):
  - when: { view_target_is: card }
    rollout: { date: 2020-01-01, delay_hours: 24 }
    data: { title: "Title" }
    
  # OLD syntax (deprecated но supported):
  - view_target_is: card
    date: 2020-01-01
    delay_hours: 24
    data: { title: "Title" }
```

**Pros:**
- ✅ **Zero breaking changes** - existing configs work
- ✅ **Gradual migration** - users can adopt incrementally
- ✅ **Flexibility** - choose appropriate syntax per case

**Cons:**
- ❌ **Parser complexity** - dual parsing logic
- ❌ **Code maintenance** - two code paths to support
- ❌ **Documentation confusion** - two ways to do same thing
- ❌ **Future tech debt** - eventually need to deprecate old syntax

### Alternative 4: Enhanced Current Structure
```yaml
content:
  # Keep current structure но improve field organization:
  - # MATCHING CONDITIONS:
    view_target_is: card
    app_status_is: any
    locale_is: any
    # ROLLOUT CONDITIONS:
    date: 2020-01-01
    delay_hours: 24
    rollout_hours: 72
    segmentation_percent: 10
    # RULE DATA:
    data:
      title: "Title"
```

**Pros:**
- ✅ **Zero breaking changes** - только documentation improvements
- ✅ **Minimal implementation** - just better organization/docs
- ✅ **Quick to implement** - mainly documentation updates

**Cons:**
- ❌ **Doesn't solve core problem** - still flat structure
- ❌ **Limited improvement** - same confusion remains
- ❌ **Missed opportunity** - doesn't address architectural issues

### Alternative 5: Gradual Field Migration
```yaml
content:
  # Phase 1: Add optional nested structure
  - view_target_is: card          # OLD: still supported
    when:                         # NEW: optional override  
      view_target_is: dialog      # overrides top-level
    data: { title: "Title" }
    
  # Phase 2: Deprecate top-level fields
  # Phase 3: Remove top-level fields
```

**Pros:**
- ✅ **Incremental migration** - multiple release cycles
- ✅ **User choice** - adopt at their pace
- ✅ **Risk mitigation** - gradual transition

**Cons:**
- ❌ **Complex validation** - priority logic between levels
- ❌ **Extended timeline** - months to complete
- ❌ **Confusing precedence** rules

## 🎯 RECOMMENDED APPROACH: Hybrid Strategy

### Hybrid Implementation Plan
**Combination Alternative 3 + Migration Tooling**

```yaml
# v1.1.0: Introduce new syntax (backward compatible)
content:
  # ✅ NEW preferred syntax:
  - when: { view_target_is: card, app_status_is: any }
    rollout: { date: 2020-01-01, delay_hours: 24 }
    data: { title: "New Syntax" }
    
  # ✅ OLD syntax (still supported):
  - view_target_is: card
    app_status_is: any  
    date: 2020-01-01
    delay_hours: 24
    data: { title: "Legacy Syntax" }

# v1.2.0: Add deprecation warnings для old syntax
# v2.0.0: Remove old syntax (major version bump)
```

### Migration Tooling Strategy
1. **Automated conversion script** - converts old → new syntax
2. **Validation tooling** - checks config correctness
3. **IDE support** - schema/autocomplete для new syntax
4. **Clear migration timeline** - 6-month transition period

## 🚧 DETAILED IMPLEMENTATION PHASES

### Phase 1: Model Design & Validation (3-4 дня)
**Goal**: Design и prototype new model structure

**Tasks:**
1. **Create new model classes**
   ```dart
   class UpdateRuleWhen {
     final List<AppStatus>? appStatusIs;
     final List<UpdateLocale>? localeIs;
     // ... all condition fields
   }
   
   class UpdateRuleRollout {  
     final UpdateDate? date;
     final Duration? delay;
     // ... all temporal fields
   }
   ```

2. **Design UpdateRuleConfig refactor**
   ```dart
   class UpdateRuleConfig<T extends Mergeable<T>> {
     final UpdateRuleWhen? when;
     final UpdateRuleRollout? rollout;
     final T data;
     
     // Backward compatibility accessors:
     List<AppStatus>? get appStatusIs => when?.appStatusIs;
     UpdateDate? get date => rollout?.date;
   }
   ```

3. **Create migration validation**
   - Sample YAML conversions
   - Readability testing
   - Edge case validation

### Phase 2: Parser Implementation (4-5 дней)
**Goal**: Implement dual syntax parsing

**Tasks:**
1. **Create nested parsers**
   - UpdateRuleWhenParser - handles when section
   - UpdateRuleRolloutParser - handles rollout section
   
2. **Modify UpdateRuleConfigParser**
   ```dart
   UpdateRuleConfig<T>? parse(...) {
     // Try NEW syntax first:
     final whenValue = map.remove('when');
     final rolloutValue = map.remove('rollout');
     
     if (whenValue != null || rolloutValue != null) {
       // NEW syntax path
       return _parseNewSyntax(whenValue, rolloutValue, dataValue);
     }
     
     // Fallback to OLD syntax:
     return _parseOldSyntax(map, dataValue);
   }
   ```

3. **Add validation warnings**
   - Deprecation warnings для old syntax
   - Migration recommendations

### Phase 3: Resolver Adaptation (2-3 дня)
**Goal**: Update всех matchers для new structure

**Tasks:**
1. **Add backward compatibility accessors**
   ```dart
   // In UpdateRuleConfig:
   List<AppStatus>? get appStatusIs => when?.appStatusIs ?? _legacyAppStatusIs;
   UpdateDate? get date => rollout?.date ?? _legacyDate;
   ```

2. **Update matcher implementations**
   - Minimal changes благодаря accessors
   - Test compatibility с both syntaxes

### Phase 4: Testing Overhaul (5-6 дней)  
**Goal**: Comprehensive test coverage для both syntaxes

**Tasks:**
1. **Update test helpers**
   ```dart
   // Support both creation styles:
   UpdateRuleConfig<UpdateContentConfig> createTestRule({
     // OLD style parameters (backward compat):
     List<UpdateViewTarget> targets,
     // NEW style parameters:
     UpdateRuleWhen? when,
     UpdateRuleRollout? rollout,
   }) {
     return when != null 
       ? UpdateRuleConfig(when: when, rollout: rollout, data: ...)  // NEW
       : UpdateRuleConfig(viewTargetIs: targets, data: ...);        // OLD
   }
   ```

2. **Dual syntax testing**
   - Test old syntax still works
   - Test new syntax works correctly
   - Test migration scenarios

### Phase 5: Documentation & Migration (3-4 дня)
**Goal**: Complete documentation и migration tools

**Tasks:**
1. **Update all documentation**
   - API documentation с new examples
   - Migration guide creation
   - Best practices update

2. **Create migration tooling**
   ```dart
   // CLI tool для automatic conversion:
   dart run app_update:migrate old_config.yaml new_config.yaml
   ```

3. **Schema validation**
   - JSON Schema для IDE support
   - Validation errors improvement

## 🎨 CREATIVE PHASE REQUIREMENTS

### 1. API Design Creative Phase 🎨
**Decisions needed:**
- **Final naming convention** (when/rollout/data vs alternatives)
- **Backward compatibility strategy** (hybrid vs clean break)
- **Migration timeline** (how long to support old syntax)
- **Error handling approach** для mixed syntaxes

### 2. Parser Architecture Creative Phase 🏗️
**Decisions needed:**
- **Dual parsing implementation** (single parser vs separate parsers)
- **Performance optimization** (caching, object reuse)
- **Error message design** для new structure
- **Validation strategy** (strict vs permissive)

### 3. Migration Strategy Creative Phase 🔄
**Decisions needed:**
- **Tooling approach** (CLI vs IDE integration vs documentation)
- **Timeline planning** (release schedule coordination)
- **Communication strategy** (deprecation warnings, changelogs)
- **Support strategy** (how long to maintain old syntax)

## ⚠️ MAJOR CHALLENGES & MITIGATIONS

### Challenge 1: Breaking Change Impact
**Problem**: 65+ файлов affected, all user configs break
**Mitigation**: 
- Implement backward compatibility period (6+ months)
- Provide automated migration tooling
- Clear communication и migration guide

### Challenge 2: Parser Complexity Increase
**Problem**: Supporting dual syntax increases code complexity
**Mitigation**:
- Clean architecture with separate parsing paths
- Comprehensive test coverage
- Clear deprecation timeline

### Challenge 3: Test Suite Overhaul
**Problem**: 1000+ lines of test code need updates
**Mitigation**:
- Update test helpers first (cascading effect)
- Maintain 95%+ coverage during migration
- Add tests для both syntaxes

### Challenge 4: Documentation Synchronization
**Problem**: Multiple documentation sources need coordination
**Mitigation**:
- Single source of truth для examples
- Automated example generation
- Version-specific documentation

## 📊 EFFORT ESTIMATION

| Phase | Files Affected | Effort (Days) | Risk Level |
|-------|----------------|---------------|------------|
| Model Design | 4 | 3-4 | 🔥 High |
| Parser Implementation | 6+ | 4-5 | 🔥 High |
| Resolver Adaptation | 9 | 2-3 | ⚠️ Medium |
| Testing Overhaul | 12+ | 5-6 | ⚠️ Medium |
| Documentation | 10+ | 3-4 | 📝 Low |
| **TOTAL** | **65+** | **17-22** | **⚠️ Significant** |

## 🚀 SUCCESS CRITERIA

### Functional Requirements
- [ ] **Both syntaxes work** correctly в all scenarios
- [ ] **Zero regression** в existing functionality
- [ ] **Migration tooling** converts configs accurately
- [ ] **Performance impact** < 5% overhead
- [ ] **Test coverage** maintains 95%+

### Quality Requirements  
- [ ] **Clear migration path** documented
- [ ] **Deprecation warnings** helpful и actionable
- [ ] **API documentation** accurate для both syntaxes
- [ ] **Error messages** guide users to correct syntax

## 💡 FINAL RECOMMENDATION

**PROCEED with Alternative 3 (Hybrid Strategy)**

**Rationale:**
1. **Risk mitigation** - backward compatibility prevents user disruption
2. **Quality preservation** - existing functionality remains intact
3. **Future benefit** - cleaner API structure eventually
4. **Migration support** - automated tooling reduces user burden

**Timeline**: 3-4 weeks для complete implementation
**Version target**: v1.1.0 (new syntax) → v2.0.0 (old syntax removal)

## Next Recommended Mode
**CREATIVE MODE** - for detailed API design decisions и implementation approach selection

---

## 🎨 CREATIVE PHASE ЗАВЕРШЕНА

### ✅ Architecture Design Complete
**Дата**: 13 сентября 2025
**Результат**: `memory-bank/creative/creative-yaml-api-restructure.md`

#### 🎯 FINAL DECISION: when/rollout/data Structure

**Selected Architecture:**
```yaml
content:
  - when:                    # 🎯 Matching conditions
      view_target_is: card
      app_status_is: any
      custom_params:
        env_is: prod
    rollout:                 # ⏰ Temporal parameters
      date: $updateReleaseDate
      delay_hours: 24
      rollout_hours: 168
      segmentation_percent: 25
    data:                    # 📄 Rule result data
      title: "Title"
      custom_params:
        analytics_track: "event"
```

#### ✅ Key Design Decisions:
1. **No backward compatibility** - clean break, complete rewrite
2. **Convenience accessors** - seamless internal code migration
3. **Composition over inheritance** - UpdateRuleWhen + UpdateRuleRollout classes
4. **Clear custom_params separation** - when (matching) vs data (storage)
5. **Future extensibility** - architecture supports new sections

#### 🔧 Implementation Architecture:
- **UpdateRuleWhen** class - all matching conditions
- **UpdateRuleRollout** class - all temporal parameters  
- **Modified UpdateRuleConfig** - composition с convenience accessors
- **New parsers** - UpdateRuleWhenParser, UpdateRuleRolloutParser
- **Backward compatible matchers** - via convenience accessors

---

## 📋 UPDATED IMPLEMENTATION PLAN

### Phase 1: Core Models (1-2 дня)
- [x] ✅ Architecture design complete
- [ ] Create UpdateRuleWhen class
- [ ] Create UpdateRuleRollout class
- [ ] Refactor UpdateRuleConfig с composition
- [ ] Add convenience accessors
- [ ] Test model compilation

### Phase 2: Parser System (2-3 дня)
- [ ] Create UpdateRuleWhenParser
- [ ] Create UpdateRuleRolloutParser  
- [ ] Rewrite UpdateRuleConfigParser main logic
- [ ] Update error handling для new structure
- [ ] Test parsing functionality

### Phase 3: Integration Validation (1-2 дня)
- [ ] Test all matchers work via accessors
- [ ] Update default rules constructors
- [ ] Validate resolver system compatibility
- [ ] Performance benchmarking

### Phase 4: Test Migration (3-4 дня)
- [ ] Update createTestRule helpers
- [ ] Migrate all YAML test fixtures
- [ ] Update test assertions
- [ ] Add new structure specific tests
- [ ] Validate 95%+ coverage

### Phase 5: Documentation Update (2-3 дня)
- [ ] Update API_v3_Documentation.md
- [ ] Update memory-bank/docs/parser.md
- [ ] Update memory-bank/docs/resolver.md
- [ ] Update all YAML examples
- [ ] Create new syntax reference

**Total Estimated Effort**: 9-14 дней
**Risk Level**: Medium (significant но straightforward changes)

## 🎯 Success Criteria (Updated)
- [ ] **Zero UnimplementedError** после migration
- [ ] **All tests pass** с new structure
- [ ] **Performance maintained** (< 5% overhead)
- [ ] **Documentation complete** с new syntax examples
- [ ] **Code quality preserved** (type safety, error handling)

## Next Mode
**IMPLEMENT MODE** - Ready для systematic implementation new YAML API structure

---

## 🎉 CREATIVE PHASE ЗАВЕРШЕНА УСПЕШНО

### 📋 Final Creative Phase Summary
**Task**: YAML API Restructuring (when/rollout/data)
**Status**: ✅ DESIGN COMPLETE
**Deliverables**: 5 comprehensive documents
**Total Documentation**: 7,220 строк

#### ✅ Creative Deliverables:
1. **`creative/creative-yaml-api-restructure.md`** - Architecture decision record
2. **`docs/API_v4_Documentation.md`** - Complete API v4 documentation  
3. **`docs/api_v4_example.yaml`** - Working example configuration
4. **`docs/parser.md`** - Updated с v4 architecture
5. **`docs/resolver.md`** - Updated с v4 semantic improvements

#### 🎯 Final Architecture: when/rollout/data

##### Semantic Structure Benefits:
```yaml
# Self-documenting business logic:
content:
  - when:                    # 🎯 "Apply when these conditions met"
      app_status_is: deprecated
      locale_is: ru
      platform_is: android
    rollout:                 # ⏰ "Control timing and rollout"
      date: $updateReleaseDate
      delay_hours: 24
      segmentation_percent: 30
    data:                    # 📄 "Show this to user"
      title: "Критическое обновление Android"
      description: "Обновитесь через Google Play"
```

#### 🔧 Implementation Architecture:
- **UpdateRuleWhen** class - grouped matching conditions
- **UpdateRuleRollout** class - grouped temporal parameters
- **Convenience accessors** - backward compatible field access
- **Enhanced parsers** - semantic error messages
- **Future extensibility** - monitoring/analytics sections ready

### 🚀 READY FOR IMPLEMENTATION MODE

#### Implementation Phases Ready:
- [x] ✅ **Phase 1 Plan**: Model classes (UpdateRuleWhen, UpdateRuleRollout)
- [x] ✅ **Phase 2 Plan**: Parser system rewrite (3 specialized parsers)
- [x] ✅ **Phase 3 Plan**: Integration testing via convenience accessors
- [x] ✅ **Phase 4 Plan**: Test migration strategy (65+ files)
- [x] ✅ **Phase 5 Plan**: Documentation alignment

#### Success Criteria Defined:
- [ ] **Zero functionality regression** through accessor compatibility
- [ ] **Improved readability** в complex rule configurations
- [ ] **Enhanced error messages** с section-specific guidance
- [ ] **Future extensibility** for monitoring/analytics features
- [ ] **95%+ test coverage** maintained через migration

### 📊 Project Status Update
- **Architecture Design**: 100% ✅ (v4 complete)
- **Ready for Implementation**: 100% ✅ 
- **Overall Progress to v1.0.0**: 75% → 80%

---

## ⏭️ NEXT MODE: IMPLEMENT

**IMPLEMENT MODE** готов для systematic implementation YAML API v4:

✅ **All design decisions made**
✅ **Architecture thoroughly planned**
✅ **Implementation phases defined**
✅ **Risk mitigation strategies ready**
✅ **Success criteria established**

**Type 'IMPLEMENT' to begin systematic implementation of new YAML API v4 architecture.**
