# womenempowermentsafety

A new Flutter project.

## Offline SOS

Emergency SOS sends a direct SMS attempt on Android without waiting for an
internet connection. Guardian numbers are read from the app's locally saved
contacts. Alerts that cannot be written to Firestore are stored in a Hive queue
and retried by WorkManager when a network is available (15-minute minimum on
Android). Background execution timing is controlled by the operating system,
especially on iOS, and is not guaranteed to run on an exact interval.

Before using SOS, open **Guardians** and choose **Enable emergency permissions**
to grant location and Android SMS access. The SOS trigger itself does not prompt
for permissions. Android SMS permissions are subject to Google Play policy and
may require a permitted core use case for distribution.

iOS cannot silently send SMS. SAKHI opens a pre-filled message for the first
guardian, and the user must tap **Send**. Location permission is still required
for a fresh location; the permission prompt does not enable automatic SMS on
iOS.

After changing dependencies, run `flutter pub get`. To regenerate the Hive
adapter, run `dart run build_runner build --delete-conflicting-outputs`.

## Android download

Build the web bundle and Android release APK together with
`bash scripts/build_hosting_release.sh`. This stages the APK at
`build/web/sakhi.apk` for the web app's **Download Android APK** button.
Deploy both files with `firebase deploy --only hosting`.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
