Add geolocator dependency

```
flutter pub add geolocator
```

Configure Android permissions in the following AndroidManifest.xml file.

AndroidManifest.xml is the required configuration file for every Android app that declares essential app metadata to the Android system — including the app's package name, permissions (e.g. camera, internet), activities, services, and the entry point of the app. Android reads it before running anything

```
android/app/src/main/AndroidManifest.xml
```

Add the following permissions in the <manifest> element, and the outside of any <application> and <acitivity> elements of the AndroidManifest.xml file. 


```
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<!-- Optional permission to get location information in the background -->
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

Configure iOS permissions in the following Info.plist file.

Info.plist is iOS's required configuration file for every app that tells the system key information about the app — including its bundle ID, display name, version, required permissions (with user-facing descriptions), and supported device orientations. Apple reads it before launching the app.

```
ios/Runner/Info.plist
```

Add the following permissions in the <dict> element of the Info.plist file.

```
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location to show your position.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs location to track your position in the background.</string>
```


To get the address from coordinates install the following package.

```
geocoding: ^4.0.0
```



