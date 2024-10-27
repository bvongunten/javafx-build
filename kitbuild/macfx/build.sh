#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Environment variables for signing & notarization needed:
#
# APPLE_DEV_SIGNING_KEY="Developer ID Application: xyz (22334455)"
# APPLE_DEV_ID="me@mail.ch"
# APPLE_DEV_TEAM_ID="22334455"
# APPLE_DEV_APP_PASSWORD="abcd-efgh-ijkl-mnop"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

REPO=~/.m2/repository
WORKINGDIR=target
SOURCEDIR=../../


ARTIFACT=ch/nostromo/fxhelloworld/1.0.0/fxhelloworld-1.0.0.jar
MAIN_CLASS=ch.nostromo.fxhelloworld.FxHelloWorld
MAIN_MODULE=fxhelloworld

PUBLIC_VERSION=1.0.0
PUBLIC_NAME="FXHelloWorld"
VENDOR="Bernhard von Gunten"
COPYRIGHT="Copyright (c) 2024 Bernhard von Gunten"
IDENTIFIER=ch.nostromo.fxhelloworld
ICON=$SOURCEDIR/src/main/deploy/osx/FxGui.icns
ENTITLEMENTS=$SOURCEDIR/src/main/deploy/osx/FxGui.entitlements


EXTERNAL_MODULES=(
  "$REPO/$ARTIFACT"
  "$REPO/org/openjfx/javafx-base/17.0.13/javafx-base-17.0.13-mac-aarch64.jar"
  "$REPO/org/openjfx/javafx-controls/17.0.13/javafx-controls-17.0.13-mac-aarch64.jar"
  "$REPO/org/openjfx/javafx-fxml/17.0.13/javafx-fxml-17.0.13-mac-aarch64.jar"
  "$REPO/org/openjfx/javafx-graphics/17.0.13/javafx-graphics-17.0.13-mac-aarch64.jar"
  "$REPO/org/openjfx/javafx-media/17.0.13/javafx-media-17.0.13-mac-aarch64.jar"
  "$REPO/org/openjfx/javafx-web/17.0.13/javafx-web-17.0.13-mac-aarch64.jar"
)

for ((i=0; i<${#EXTERNAL_MODULES[@]}; i++ ))
do
    MODPATH=${MODPATH}":""${EXTERNAL_MODULES[$i]}"
done

echo Deleting working dir ...
rm -rf $WORKINGDIR

echo Running jlink ...
jlink \
  --module-path $MODPATH  \
  --add-modules $MAIN_MODULE  \
  --add-modules jdk.crypto.ec  \
  --launcher $PUBLIC_NAME=$MAIN_MODULE/$MAIN_CLASS  \
  --output $WORKINGDIR/app-vmimage

echo Creating Application ...
jpackage \
  --type app-image \
  --dest $WORKINGDIR \
  --name $PUBLIC_NAME \
  --vendor "\$VENDOR" \
  --module $MAIN_MODULE/$MAIN_CLASS \
  --icon $ICON \
  --app-version $PUBLIC_VERSION \
  --runtime-image $WORKINGDIR/app-vmimage \
  --mac-sign \
  --mac-entitlements $ENTITLEMENTS \
  --mac-signing-key-user-name "$APPLE_DEV_SIGNING_KEY" \
  --mac-package-identifier $IDENTIFIER


echo Sign Application ...
codesign \
    --entitlements $ENTITLEMENTS \
    --options runtime \
    --force \
    --sign "$APPLE_DEV_SIGNING_KEY" \
    $WORKINGDIR/$PUBLIC_NAME.app

echo Create DMG ...
jpackage \
  --type dmg \
  --dest $WORKINGDIR \
  --name $PUBLIC_NAME \
  --app-image $WORKINGDIR/$PUBLIC_NAME.app \
  --icon $ICON \
  --mac-sign \
  --mac-signing-key-user-name "$APPLE_DEV_SIGNING_KEY" \
  --mac-package-identifier $IDENTIFIER \
  --mac-package-name $PUBLIC_NAME \
  --mac-entitlements $ENTITLEMENTS \
  --vendor "$VENDOR" \
  --app-version $PUBLIC_VERSION \
  --copyright "\$COPYRIGHT"

echo Notarize ...
xcrun \
  notarytool \
  submit \
  --apple-id $APPLE_DEV_ID \
  --team-id $APPLE_DEV_TEAM_ID \
  --password $APPLE_DEV_APP_PASSWORD \
  $WORKINGDIR/$PUBLIC_NAME-$PUBLIC_VERSION.dmg \
  --wait

echo Staple ...

xcrun \
  stapler \
  staple \
  $WORKINGDIR/$PUBLIC_NAME-$PUBLIC_VERSION.dmg
