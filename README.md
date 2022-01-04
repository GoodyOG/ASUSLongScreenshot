# ASUS Long screenshot port for Android 9-12
Asus screenshot port with QS tile & Tasker plugin support.

The QS shortcut is based on PixelExperience implementation for the Qs Tile (big thanks and credits to PE team).

** **This module only works in roms signed with AOSP's public release-keys.** **
# Changelog
## 2022-01-04 (5.0.1)
 - Update maximum api level to 32 **untested**.
 - Abort installation in ROMS not signed with AOSP's public release-keys.
## 2021-11-01 (5.0.0)
 - Updated Stitchimage from asus/WW_I006D/ASUS_I006D:11/RKQ1.201022.002/30.12.112.36:user/release-keys
 - Works on Android 12 (Tested on Evolution X 6.0)
## 2021-08-15 (4.0)
 - Updated Stitchimage from asus/WW_I002D/ASUS_I002D:11/RKQ1.200710.002/30.41.69.89_20210728:user/release-keys OTA
 - LongshotQS app
   - Migration to Kotlin
   - New app icon because why not
   - Added screenshot delays
      >  Tapping Tile changes screenshot delay, longpress takes screenshot
   - Show delay in QS icon and QS subtitle (subtitles need API level 29+)
   - Updated QS icons
   - Add Tasker Action to start screenshot service

