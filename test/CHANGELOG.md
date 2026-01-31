## v2.5.0
#### Update
- Update to support Flutter 3.16+ and Dart 3.0+
- **BREAKING**: Update Android Usabilla SDK to v9.+ (from v8.+)
- **BREAKING**: Android minSdk increased to 24 (from 21) - required by Usabilla SDK v9
- Update Android Gradle Plugin to 8.2.2
- Update Kotlin version to 1.9.22
- Update compileSdk/targetSdk to 35 for Android
- Update AndroidX dependencies to latest versions
- Fix deprecated test API usage
- Improve type safety in Dart code
- Fix deprecated iOS UIApplication.shared.keyWindow API

#### Migration Notes
- Apps must now support Android API 24+ (Android 7.0 Nougat)
- For older device support, continue using flutter_usabilla v2.4.x with Usabilla SDK v8.x

## v2.4.0
#### Update
- Add support for Gradle 8
- Use JVM 1.8 for the Kotlin compiler

## v2.3.1
#### Fix
- Remove unwanted imports for android

## v2.3.0
#### Fix
- Fix Integration with android sdk v8.+
- Fix android sample app with standard events

## v2.2.2
#### Fix
- Custom variable callback

## v2.2.1
#### Fix
- Rename breaking variable

## v2.2.0
#### Update
- Added Standard Events

## v2.1.0
#### Update
- Kotlin version to 1.6.10
- Gradle build tool to 7.1.2
- CompileSdkVersion to 31
- Dependency AndroidX annotation to 1.3.0
- Dependency AndroidX fragment-ktx to 1.4.1

## v2.0.1
#### Fix
- Broadcast receiver duplication

## v2.0.0
#### Fix
- Migration to null-safety
- Minor bugs
#### Update
- Dependencies

## v1.1.0
#### Update
- Documentation

## v1.0.1
#### Update
- Documentation

## v1.0.0
#### Add
- Android features as explained in [Usabilla Native Android SDK](https://github.com/usabilla/usabilla-u4a-android-sdk)
- iOS features as explained in [Usabilla Native IOS SDK](https://github.com/usabilla/usabilla-u4a-ios-swift-sdk)
