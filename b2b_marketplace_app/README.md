# B2B Marketplace App

This is a Flutter project built with a feature-first architecture, Riverpod for state management, and go_router for navigation. It supports web and mobile platforms, includes theming, internationalization, and CI/CD setup.

## Getting Started

### Prerequisites

- Flutter SDK (version 3.x or higher)
- Dart SDK (version 3.x or higher)

### Installation

1.  Clone the repository:
    ```bash
    git clone https://github.com/your-username/b2b_marketplace_app.git
    cd b2b_marketplace_app
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Generate Freezed/JSON Serializable files (if models are modified):
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```
4.  Generate localization files:
    ```bash
    flutter gen-l10n
    ```

### Running the Application

#### Web

To run the application in a web browser:
```bash
flutter run -d chrome
```

To build the web application for deployment:
```bash
flutter build web --release
```
The build artifacts will be in the `build/web` directory.

#### Mobile (iOS/Android)

To run on an iOS simulator or Android emulator/device:
```bash
flutter run
```
(Select your desired device from the list)

To build for iOS:
```bash
flutter build ios
```

To build for Android:
```bash
flutter build apk
```
or
```bash
flutter build appbundle
```

### Customization

#### Changing Colors and Fonts

The application's theme (colors, typography) is defined in `lib/core/theme/app_theme.dart`.
-   **Colors**: Modify `AppColors` class for primary, secondary, and neutral colors.
-   **Typography**: Adjust `textTheme` properties within `AppTheme.lightTheme` and `AppTheme.darkTheme` for font sizes, weights, and colors.

#### Internationalization (i18n)

Localization strings are managed using Flutter's `gen_l10n` tool.
-   **Dictionaries**: Localization files are located in `lib/l10n/`.
    -   `app_en.arb`: English translations.
    -   `app_ru.arb`: Russian translations.
-   **Adding new strings**: Add new key-value pairs to the `.arb` files.
-   **Generating code**: After modifying `.arb` files, run `flutter gen-l10n` to regenerate the localization classes.
-   **Using translations**: Access translated strings in your widgets using `AppLocalizations.of(context)!.yourStringKey`.

### Project Structure

The project follows a feature-first architecture:
-   `lib/features/`: Contains independent features (e.g., `home`, `opportunities`, `blog`).
-   `lib/core/`: Contains shared core components (e.g., `theme`, `router`, `models`, `widgets`, `utils`).
-   `lib/l10n/`: Localization files.

### Testing

-   **Unit/Widget Tests**: Located in the `test/` directory. Run with `flutter test`.
-   **Golden Tests**: Configured using `golden_toolkit`. Test setup is in `test/golden_test_setup.dart`. Run with `flutter test`.

### Continuous Integration (CI)

A GitHub Actions workflow is configured in `.github/workflows/ci.yaml` to automate:
-   Code formatting (`flutter format`)
-   Linting (`flutter analyze`)
-   Running tests (`flutter test`)
-   Building the web application (`flutter build web`)
-   Uploading web build artifacts.

## License

This project is licensed under the MIT License.