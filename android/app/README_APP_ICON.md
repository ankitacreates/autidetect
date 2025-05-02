# Replacing the App Icon for AutiDetect

This README provides instructions on how to replace the app icon for both Android and iOS platforms.

## Android App Icon Replacement

The AutiDetect icon (`autidetect_icon.png`) should be used to generate various sizes of app icons for Android. Replace the default Flutter icon in the following directories:

1. `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (48x48 px)
2. `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72 px)
3. `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96 px)
4. `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144 px)
5. `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192 px)

### Using Android Studio / Icon Generator

1. Right-click on the `res` folder
2. Select "New" > "Image Asset"
3. Choose "Icon Type" as "Launcher Icons (Adaptive and Legacy)"
4. Under "Path", select the `autidetect_icon.png` file from `assets/images/`
5. Adjust settings as needed and click "Next", then "Finish"

### Using Command Line / Image Assets Generator

You can also use tools like [Image Asset Studio](https://developer.android.com/studio/write/image-asset-studio) or online app icon generators to create all the necessary sizes.

## iOS App Icon Replacement

For iOS, replace the icons in:
`ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### Using Xcode

1. Open the iOS module in Xcode 
2. Navigate to Assets.xcassets
3. Select AppIcon
4. Drag and drop the appropriate sized icons

### Using Flutter Launcher Icons Package

For both Android and iOS, you can use the [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) package:

1. Add to pubspec.yaml:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: "ic_launcher"
  ios: true
  image_path: "assets/images/autidetect_icon.png"
  adaptive_icon_background: "#141B41" # Dark Blue
  adaptive_icon_foreground: "assets/images/autidetect_icon.png"
```

2. Run the following command:
```
flutter pub get
flutter pub run flutter_launcher_icons
```

This will automatically generate all the necessary icon sizes for both platforms.

## Verification

After replacing the icons, build and run the app to verify that the new icon appears correctly on the app launcher. 