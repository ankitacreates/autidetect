# AutiDetect App Logo

This directory contains the SVG source files for the AutiDetect app logo and icon.

## Logo Description

The logo represents the concept of autism detection with:
- A brain outline to symbolize cognitive and neural aspects
- Autism puzzle pieces inside, representing the autism awareness symbol
- App's color palette:
  - Dark Blue: #141B41
  - Medium Blue: #306BAC
  - Light Blue: #6F9CEB
  - Very Light Blue/Periwinkle: #98B9F2
  - Lavender: #8D8AF0

## SVG to PNG Conversion

The SVG files need to be converted to PNG for use in the app. You can do this using various tools:

### Option 1: Using Inkscape (Recommended)
```
inkscape -w 512 -h 512 autidetect_icon.svg -o autidetect_icon.png
inkscape -w 1024 -h 512 autidetect_logo.svg -o autidetect_logo.png
```

### Option 2: Using ImageMagick
```
magick convert -background none -size 512x512 autidetect_icon.svg autidetect_icon.png
magick convert -background none -size 1024x512 autidetect_logo.svg autidetect_logo.png
```

### Option 3: Online Converters
You can use online tools like:
- [SVG to PNG Converter](https://svgtopng.com/)
- [Convertio](https://convertio.co/svg-png/)

After conversion, make sure to update the launcher icons configuration in the pubspec.yaml file if necessary.

## Integration with Flutter

The icons are referenced in the pubspec.yaml file under the flutter_launcher_icons section.

## Assets Included

- `autidetect_logo.svg` - Vector logo for the application (better for scaling)
- `autidetect_logo.png` - PNG version of the logo for use in the app UI
- `autidetect_icon.svg` - Vector app icon in circular format (better for scaling)
- `autidetect_icon.png` - PNG version of the app icon for app launchers

## Usage

### In Flutter Code

```dart
// For using the logo in the app
Image.asset('assets/images/autidetect_logo.png')

// For using the icon in the app
Image.asset('assets/images/autidetect_icon.png')
```

### App Icon

To set the application icon, you'll need to replace the default icon in:
- Android: `android/app/src/main/res/mipmap-*` directories
- iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset`

Follow Flutter's documentation for detailed instructions on setting app icons for different platforms.

### Logo Design Elements

The logo incorporates:
1. A stylized "A" representing "Auti" (Autism)
2. A brain symbol representing cognitive assessment
3. Connecting neural lines representing network/detection
4. The AutiDetect name in the text version

These elements symbolize the app's purpose of autism detection and support through modern technology. 