# IUC Park 🏍️📱

Welcome to **IUC Park**, a Flutter-based Android application for efficient motorbike parking management! 🌟 This app enables parking attendants to check in and check out motorbikes using coupon codes, export parking records, and store data offline in a SQLite database. With a modern UI and robust offline capabilities, it’s designed for seamless use in parking facilities.


---

## ✨ Features

- **Check-In System** 🏍️: Assign coupon codes (1–300) and plate numbers to motorbikes.
- **Check-Out System** ✅: Two-step verification for accurate check-outs.
- **Export Records** 📄: Generate text file reports by date or plate number, saved to device storage.
- **Offline Storage** 💾: SQLite database (`iucpark.db`) ensures data persistence offline.
- **Simple Authentication** 🔐: Admin login with username `admin` and password `123`.
- **Modern UI** 🎨: Red gradient accents, card-based layouts, and responsive navigation.
- **Data Migration** 🔄: Migrates legacy `vehicles.dat` to SQLite via `migrate.dart`.

---

## 📸 Screenshots

Explore the app’s intuitive interface:

| **Login Screen** | **Home Screen** | **Export Screen** |
|------------------|-----------------|-------------------|
| ![Login Screen](https://raw.githubusercontent.com/afriwondimu/IUC-Park-android-app/refs/heads/main/assets/screenshots/Loginsample.jpg) | ![Home Screen](https://raw.githubusercontent.com/afriwondimu/IUC-Park-android-app/refs/heads/main/assets/screenshots/homesample.jpg) | ![Export Screen](https://raw.githubusercontent.com/afriwondimu/IUC-Park-android-app/refs/heads/main/assets/screenshots/exportssample.jpg) |
| Secure admin login | Check-in/check-out hub | Export parking records |

---

## 📂 Project Structure

```
lib/
├── widgets/                  # Reusable UI components
│   ├── bottom_bar.dart       # Bottom navigation bar (Home, Export, Logout)
│   ├── check_in.dart         # Check-in form
│   ├── check_out.dart        # Check-out form with confirmation
│   ├── export_form.dart      # Export records form
├── models/                   # Data models
│   ├── motorbike.dart        # Motorbike class extending Vehicle
│   ├── vehicle.dart          # Abstract Vehicle class
├── services/                 # Business logic and data services
│   ├── auth_service.dart     # Authentication logic
│   ├── check_in_service.dart # Check-in operations
│   ├── check_out_service.dart# Check-out operations
│   ├── database_service.dart # SQLite database management
│   ├── export_service.dart   # Export records to text files
│   ├── file_service.dart     # File handling utilities
├── screens/                  # Full-screen UI pages
│   ├── export_screen.dart    # Export records screen
│   ├── home_screen.dart      # Main screen with check-in/check-out
│   ├── login_screen.dart     # Login screen
├── app_state.dart            # Global state management with Provider
├── main.dart                 # App entry point
├── migrate.dart              # One-time migration from vehicles.dat to SQLite
assets/                       # Static assets
├── splash/                   # Splash screen image
│   ├── light.png
├── icon/                     # App icons
│   ├── appicon.png
│   ├── icon.png
```

---

## 🛠️ Getting Started

### Prerequisites
- **Flutter SDK**: Version 3.5.4 or higher
- **Dart SDK**: Included with Flutter
- **Android Emulator** or physical Android device
- **IDE**: VS Code, Android Studio, or IntelliJ IDEA

### Installation
1. **Clone the Repository** 📥
   ```bash
   git clone https://github.com/afriwondimu/IUC-Park-android-app.git
   cd IUC-Park-android-app
   ```

2. **Install Dependencies** 📦
   ```bash
   flutter pub get
   ```

3. **Run Migration** 🔄
   - Use `migrate.dart` to convert legacy `vehicles.dat` to SQLite (`iucpark.db`).
   - Run the app once with `migrate.dart` as the entry point (replace `main.dart`’s `main()` temporarily).
   - After migration, revert to `main.dart` or remove `migrate.dart`.

4. **Generate Icons** 🖼️
   ```bash
   flutter pub run flutter_launcher_icons
   ```

5. **Set Up Splash Screen** 🌟
   ```bash
   flutter pub run flutter_native_splash:create
   ```

6. **Launch the App** 🚀
   ```bash
   flutter run
   ```

7. **Login** 🔑
   - Username: `admin`
   - Password: `123`

---

## 📱 Usage

1. **Login**: Sign in with admin credentials.
2. **Home Screen**: Manage motorbike parking via Check-In and Check-Out cards.
   - **Check-In**: Input coupon code (1–300) and plate number.
   - **Check-Out**: Enter coupon code, confirm plate number, and finalize.
3. **Export Records**: Use the Export screen (via bottom navigation) to create reports by date or plate number.
4. **Logout**: Sign out from the bottom navigation bar.

---

## 🔧 Configuration

### Dependencies (`pubspec.yaml`)
- `flutter`: Core SDK
- `provider: ^6.1.2`: State management
- `sqflite: ^2.3.3+1`: SQLite database
- `path_provider: ^2.1.5`: File system access
- `permission_handler: ^11.3.1`: Storage permissions
- `google_nav_bar: ^5.0.7`: Bottom navigation
- `flutter_native_splash: ^2.4.4`: Splash screen
- `intl: ^0.19.0`: Date formatting
- `device_info_plus: ^10.1.2`: Device info
- `cupertino_icons: ^1.0.8`: iOS-style icons
- `flutter_launcher_icons: ^0.14.3`: App icon generation

Run `flutter pub outdated` to check for updates.

### Assets
- **Splash Screen**: `assets/splash/light.png` (configured in `flutter_native_splash.yaml`).
- **App Icons**: `assets/icon/appicon.png` and `assets/icon/icon.png`.
- **pubspec.yaml**:
  ```yaml
  assets:
    - assets/icon/icon.png
    - assets/icon/appicon.png
    - assets/splash/light.png
  ```

### Permissions
- **Android**: Storage permissions (`READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`, `MANAGE_EXTERNAL_STORAGE`) in `android/app/src/main/AndroidManifest.xml` for exporting reports.

---

## 🗄️ Data Storage

- **SQLite** (`iucpark.db`): Stores parking records in the app’s documents directory, persisting offline until uninstalled.
- **Migration**: `migrate.dart` converts `vehicles.dat` to SQLite and deletes the `.dat` file.
- **Exports**: Reports are saved as text files in `/storage/emulated/0/IUC/` or the app’s external storage.

---

## 🎨 UI Design

- **Red Gradient Accents**: Circular gradients on screens.
- **Card Layouts**: Check-In, Check-Out, and Export forms in elevated cards.
- **Navigation**: Bottom bar with Home, Export, and Logout tabs.
- **Splash Screen**: Custom image (`assets/splash/light.png`).

---

## 🤝 Contributing

1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/your-feature`).
3. Commit changes (`git commit -m 'Add your feature'`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a Pull Request.

---

## 📜 License

MIT License. See [LICENSE](LICENSE) for details.

---

## 📬 Contact

- **GitHub**: [afriwondimu](https://github.com/afriwondimu)
- **Issues**: [Report bugs or suggest features](https://github.com/afriwondimu/IUC-Park-android-app/issues)
