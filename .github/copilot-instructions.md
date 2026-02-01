# GOH Calculator - AI Coding Assistant Instructions

## Project Overview

**GOH Calculator** is a Flutter application for the game "Greed of Hercules" that provides damage/gold calculators, stage configurations, and game item management (accessories, enhancements). It integrates Firebase Realtime Database for dynamic content and Firebase Storage for assets.

### Architecture Pattern
**Clean Architecture** with Clear Layer Separation:
- **Presentation** (`lib/presentation/`) - UI screens & widgets
- **Domain** (`lib/domain/`) - Business logic and calculations  
- **Data** (`lib/data/`) - Models and Firebase data sources
- **Core** (`lib/core/`) - Constants, services, and cross-cutting concerns

## Critical Knowledge

### 1. Firebase Integration
The app loads **essential data at startup** from Firebase:

**File**: [lib/main.dart](../lib/main.dart) (lines 14-26)
- `Firebase.initializeApp()` initializes Firebase
- `AccessoryDataManager().loadAccessories()` fetches accessory data from `/accessories` path
- **Critical Pattern**: Accessories include Firebase Storage URLs in format `https://firebasestorage.googleapis.com/v0/b/gohcalculator.firebasestorage.app/o/accessories%2F{id}.png?alt=media`
  - Note: Storage bucket is `gohcalculator.firebasestorage.app` (NOT `goh-calculator.appspot.com`)
  - IDs are case-sensitive and must be URI-encoded

**File**: [lib/core/constants/accessory_constants.dart](../lib/core/constants/accessory_constants.dart) (lines 6-72)
- `AccessoryDataManager` is a **singleton** managing all accessory data
- Automatically generates Firebase Storage URLs on load
- Must be initialized before UI renders

### 2. State Management
Uses **StatefulWidget + setState()** pattern (no external provider libraries):
- Local widget state only; no global state manager
- Each screen manages its own form state via `GlobalKey<FormState>`
- Example: [lib/presentation/stage_settings/settings_screen.dart](../lib/presentation/stage_settings/settings_screen.dart) uses `_formKey.currentState?.validate()`

**Persistence**: [lib/core/services/settings_service.dart](../lib/core/services/settings_service.dart)
- `AppSettings` class serialized to/from `SharedPreferences`
- Contains dark mode, font multiplier, stage visibility filters, calendar start day
- Must call `copyWith()` for immutable updates

### 3. Data Constants & Stage Configuration
**File**: [lib/core/constants/stage_constants.dart](../lib/core/constants/stage_constants.dart)
- `stageNameList` getter returns all available stages (normal + event stages)
- Stage data imported from `lib/data/datasources/stage_data/{stage_name}.dart`
- Event stages dynamically added via `EventManager.isEventPeriodActive()`
- **Pattern**: Use getter, not cached values, for stage list

**File**: [lib/core/constants/accessory_constants.dart](../lib/core/constants/accessory_constants.dart) (lines 105-160)
- `AccessoryOptionNames` manages all option names as constants
- Options categorized: percentage increases, percentage decreases, flat increases
- `getConstantName()` validates Korean option names exist in `_allOptionNames` set

### 4. Calculation Logic
**File**: [lib/domain/logic/calculator_logic.dart](../lib/domain/logic/calculator_logic.dart)
- Pure calculation functions for stamina, gold, damage
- Depends on constants from `lib/core/constants/` (team levels, VIP levels, leaders)
- Example calculation chain:
  1. Base value from constants
  2. Team level bonus lookup
  3. VIP bonus accumulation
  4. Leader multiplier application

**File**: [lib/domain/logic/accessory_enhancement_logic.dart](../lib/domain/logic/accessory_enhancement_logic.dart)
- Accessory enhancement calculations
- Integrates `AccessoryOptionNames` for option validation

### 5. Data Models
**File**: [lib/data/models/accessory.dart](../lib/data/models/accessory.dart)
- `Accessory` class with `fromJson()` factory deserializes Firebase data
- `imageUrl` auto-generated if not provided in JSON
- Options parsed as list of `AccessoryOption` objects
- **New**: `setOptions` field for set bonuses with multiple effects per set

**Common Pattern**: Models have `fromJson()` factory & implement JSON serialization

### 6. Localization
- Uses `intl` package with Korean localization
- `initializeDateFormatting()` called in `main()` before rendering
- Compatibility: `intl: ^0.19.0` with `table_calendar: ^3.1.3`

## Developer Workflows

### Build & Run
```bash
flutter pub get          # Install dependencies
flutter run             # Run on default device
flutter run -d chrome   # Run on web
flutter build web       # Build web (use ./deploy.bat to auto-deploy)
flutter build apk       # Build Android APK
```

### Web Deployment
```bash
.\deploy.bat            # Build + Auto-deploy to GitHub Pages (https://blaxxs.github.io/goh/)
flutter build web       # Build only (for testing)
```

### Git Workflow
Workspace has auto-commit tasks:
- `auto-commit.sh` / `autocommit.bat` - Auto-commits changes
- `deploy.sh` / `deploy.bat` - Deploy web build to GitHub Pages

### Common Development Tasks

**Adding a New Stage**: 
1. Create datasource in `lib/data/datasources/stage_data/{name}.dart`
2. Import in [stage_constants.dart](../lib/core/constants/stage_constants.dart)
3. Stage appears in `stageNameList` automatically

**Adding Accessory Options**:
1. Add constant to `AccessoryOptionNames` class
2. Add to `_allOptionNames` set (for validation)
3. Update Firebase `/accessories` path data

**Adding Set Bonuses to Accessories**:
1. Add `setOptions` array to Firebase accessory JSON (optional field)
2. Specify `setId`, `setName`, `requiredAccessories`, `requiredAccessoryImages`
3. Define `effects` array with option names and `stageValues` (0-18 levels)
4. UI automatically displays set bonuses in accessory detail dialog

**Modifying Settings**:
1. Update `AppSettings` class in [settings_service.dart](../lib/core/services/settings_service.dart)
2. Add to `fromJson()`, `toJson()`, `copyWith()`
3. Update UI form in settings screen

## Code Patterns & Conventions

### Naming
- **Korean comments** used extensively for domain-specific logic
- **Static const** for UI strings and option names
- **File structure** mirrors conceptual layers (presentation, domain, data, core)

### Error Handling
- Firebase errors logged via `debugPrint()` in try-catch blocks
- App continues with empty data if Firebase fails (graceful degradation)
- Example: [main.dart](../lib/main.dart) lines 14-24
- **Accessory parsing**: Null-safe with fallback for missing `setOptions`

### Form Validation
- `FormState` keys used: `_formKey.currentState?.validate()`
- Custom validators check numeric ranges and business rules
- Example: [settings_screen.dart](../lib/presentation/stage_settings/settings_screen.dart) line 100

### Async Operations
- Firebase calls wrapped in try-catch
- `await` used for sequential operations in `main()`
- Widget build methods remain synchronous (no blocking I/O)

## Common Pitfalls to Avoid

1. **Firebase Storage URLs**: Always use `gohcalculator.firebasestorage.app` bucket and URI-encode IDs
2. **Accessory Data Freshness**: AccessoryDataManager is singleton; reload requires explicit call
3. **Settings Persistence**: Use `copyWith()` for updates; direct assignment won't persist
4. **Stage Constants**: Call `stageNameList` getter each time; don't cache (events are dynamic)
5. **Localization**: Initialize date formatting before rendering; missing causes crashes on web
6. **Set Options Parsing**: Firebase returns dynamic types; use `dynamic` parameter in `fromJson()` for safety

## File Reference Guide

| File | Purpose | Key Pattern |
|------|---------|------------|
| [lib/main.dart](../lib/main.dart) | App entry, Firebase init, Accessory load | Startup sequencing |
| [lib/core/services/settings_service.dart](../lib/core/services/settings_service.dart) | User preferences | Singleton + SharedPreferences |
| [lib/core/constants/accessory_constants.dart](../lib/core/constants/accessory_constants.dart) | Accessory metadata, option names | Firebase data manager |
| [lib/core/constants/stage_constants.dart](../lib/core/constants/stage_constants.dart) | Stage data, dynamic events | Getter-based stage list |
| [lib/domain/logic/calculator_logic.dart](../lib/domain/logic/calculator_logic.dart) | Calculation engine | Pure functions + constants |
| [lib/data/models/accessory.dart](../lib/data/models/accessory.dart) | Accessory structure | fromJson() factory pattern |
| [lib/presentation/stage_settings/](../lib/presentation/stage_settings/) | Settings UI | StatefulWidget + FormState |
| [lib/presentation/accessory/](../lib/presentation/accessory/) | Accessory compendium | Grid + set bonus display |

## Questions to Ask When Adding Features

- **Is this game data or user configuration?** (→ Firebase or SharedPreferences)
- **Should this calculation vary by stage/VIP/leader?** (→ Add to relevant constants)
- **Does this need persistence?** (→ Add to AppSettings or Firebase)
- **Is this displayed in settings?** (→ Add form field + validation to settings_screen)
- **Is this a set bonus?** (→ Add optional `setOptions` field to accessory in Firebase)

