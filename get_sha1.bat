@echo off
echo Getting SHA-1 fingerprint for Google Sign-In...
echo.

cd android
call gradlew signingReport

echo.
echo ============================================
echo Copy the SHA-1 fingerprint from above
echo and add it to Firebase Console:
echo https://console.firebase.google.com/
echo Project Settings > Your App > Add Fingerprint
echo ============================================
pause

