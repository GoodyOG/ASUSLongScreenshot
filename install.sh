##########################################################################################
#
# Magisk Module Installer Script
#
##########################################################################################
##########################################################################################
#
# Instructions:
#
# 1. Place your files into system folder (delete the placeholder file)
# 2. Fill in your module's info into module.prop
# 3. Configure and implement callbacks in this file
# 4. If you need boot scripts, add them into common/post-fs-data.sh or common/service.sh
# 5. Add your additional or modified system properties into common/system.prop
#
##########################################################################################

##########################################################################################
# Config Flags
##########################################################################################

# Set to true if you do *NOT* want Magisk to mount
# any files for you. Most modules would NOT want
# to set this flag to true
SKIPMOUNT=false

# Set to true if you need to load system.prop
PROPFILE=false

# Set to true if you need post-fs-data script
POSTFSDATA=false

# Set to true if you need late_start service script
LATESTARTSERVICE=false

##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# Check the documentations for more info why you would need this

# Construct your list in the following format
REPLACE="
"

##########################################################################################
#
# Function Callbacks
#
# The following functions will be called by the installation framework.
# You do not have the ability to modify update-binary, the only way you can customize
# installation is through implementing these functions.
#
# When running your callbacks, the installation framework will make sure the Magisk
# internal busybox path is *PREPENDED* to PATH, so all common commands shall exist.
# Also, it will make sure /data, /system, and /vendor is properly mounted.
#
##########################################################################################
##########################################################################################
#
# The installation framework will export some variables and functions.
# You should use these variables and functions for installation.
#
# ! DO NOT use any Magisk internal paths as those are NOT public API.
# ! DO NOT use other functions in util_functions.sh as they are NOT public API.
# ! Non public APIs are not guranteed to maintain compatibility between releases.
#
# Available variables:
#
# MAGISK_VER (string): the version string of current installed Magisk
# MAGISK_VER_CODE (int): the version code of current installed Magisk
# BOOTMODE (bool): true if the module is currently installing in Magisk Manager
# MODPATH (path): the path where your module files should be installed
# TMPDIR (path): a place where you can temporarily store files
# ZIPFILE (path): your module's installation zip
# ARCH (string): the architecture of the device. Value is either arm, arm64, x86, or x64
# IS64BIT (bool): true if $ARCH is either arm64 or x64
# API (int): the API level (Android version) of the device
#
# Availible functions:
#
# ui_print <msg>
#     print <msg> to console
#     Avoid using 'echo' as it will not display in custom recovery's console
#
# abort <msg>
#     print error message <msg> to console and terminate installation
#     Avoid using 'exit' as it will skip the termination cleanup steps
#
# set_perm <target> <owner> <group> <permission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     this function is a shorthand for the following commands
#       chown owner.group target
#       chmod permission target
#       chcon context target
#
# set_perm_recursive <directory> <owner> <group> <dirpermission> <filepermission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     for all files in <directory>, it will call:
#       set_perm file owner group filepermission context
#     for all directories in <directory> (including itself), it will call:
#       set_perm dir owner group dirpermission context
#
##########################################################################################
##########################################################################################
# If you need boot scripts, DO NOT use general boot scripts (post-fs-data.d/service.d)
# ONLY use module scripts as it respects the module status (remove/disable) and is
# guaranteed to maintain the same behavior in future Magisk releases.
# Enable boot scripts by setting the flags in the config section above.
##########################################################################################

# Set what you want to display when installing your module

print_modname() {
  ui_print "*********************************"
  ui_print "* ASUS Long Screenshot port     *"
  ui_print "* Support: Android 9-12         *"
  ui_print "* Version: 5.0.1                *"
  ui_print "* By: @luisbocanegra            *"
  ui_print "*********************************"
}

# Copy/extract your module files into $MODPATH in on_install.

on_install() {
  # The following is the default implementation: extract $ZIPFILE/system to $MODPATH
  # Extend/change the logic to whatever you want
  target_platform_cert='MIIBIDANBgkqhkiG9w0BAQEFAAOCAQ0AMIIBCAKCAQEAnHgFkqwNXTgc3qpl7MimAG42SAxtcgexIBG+UIY6q+K1XQCa33FG1vIgIoDHzU172yYkO4qAbCazSxN1I6SSaCJJBNwBST58Cs8aBch09psDe2AwnZB00kKA4WutKoc0NhlR6vcqSC0JsgSxh14SrJjBqnc9aAC56v3lbVi+2OjaFvmjYAmcN6g0pt/tt7a0SgSeB6Jp/M8sVJbyzzbWTfkKO42PNKO6q0z1M3GrJ3GbO6WHVK0MU/wU4dtF1R4jT7vpPJuk7fnOVCYTUOxTVge/aaL/SqB9tffqIA0JpsG0niFAL4ntEZCJOqtakYDxUugvhaRXU89fwZBxxe7IJwIBAw=='
  android_package_cert_index=$(cat /data/system/packages.xml | grep 'package name="android"' -A 999 | grep proper-signing-keyset | head -1 | tr -d -c 0-9)
  device_platform_cert=$(cat /data/system/packages.xml | grep -e "public-key identifier=\"${android_package_cert_index}\"" | sed -e "s/<public-key identifier=\"${android_package_cert_index}\" value=\"\(.*\)\"\(.*\)\/>/\1/" | tr -d ' ')
  
  if $BOOTMODE; then
    if [[ "$target_platform_cert" == "$device_platform_cert" ]]; then
      if [ $API -lt 28 ] || [ $API -gt 32 ]; then
        abort "Error: API $API is not supported :("
      fi
    else
      ui_print "Error: Incompatible platform signature :("
      abort "ROM is not signed with AOSP's public release-keys"
    fi
  else
    abort "Error: Please install from Magisk app"
  fi

  ui_print "- Extracting module files"
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
  set_permissions
}

# Only some special files require specific permissions
# This function will be called after on_install is done
# The default permissions should be good enough for most cases

set_permissions() {
  # The following is the default rule, DO NOT remove
  set_perm_recursive $MODPATH 0 0 0755 0644

  # Here are some examples:
  # set_perm_recursive  $MODPATH/system/lib       0     0       0755      0644
  # set_perm  $MODPATH/system/bin/app_process32   0     2000    0755      u:object_r:zygote_exec:s0
  # set_perm  $MODPATH/system/bin/dex2oat         0     2000    0755      u:object_r:dex2oat_exec:s0
  # set_perm  $MODPATH/system/lib/libart.so       0     0       0644
}

# You can add more functions to assist your custom script code
