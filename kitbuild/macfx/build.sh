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


ARTIFACT_ID=fxhelloworld
ARTIFACT_VERSION=1.0.0
IDENTIFIER=ch.nostromo.fxhelloworld
MAINCLASS=ch.nostromo.fxhelloworld.FxHelloWorld
MAINMODULE=fxhelloworld

VERSION=1.0.0
PROJECT_NAME="FXHelloWorld"
VENDOR="Bernhard von Gunten"
COPYRIGHT="Copyright (c) 2024 Bernhard von Gunten"
ICON=$SOURCEDIR/src/main/deploy/osx/FxGui.icns
ENTITLEMENTS=$SOURCEDIR/src/main/deploy/osx/FxGui.entitlements

EXTERNAL_MODULES=(
  "$REPO/ch/nostromo/$ARTIFACT_ID/$ARTIFACT_VERSION/$ARTIFACT_ID-$ARTIFACT_VERSION.jar"
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
  --add-modules $MAINMODULE  \
  --add-modules jdk.crypto.ec  \
  --launcher $PROJECT_NAME=$MAINMODULE/$MAINCLASS  \
  --output $WORKINGDIR/app-vmimage

echo Creating Application ...
jpackage \
  --type app-image \
  --dest $WORKINGDIR \
  --name $PROJECT_NAME \
  --vendor "\$VENDOR" \
  --module $MAINMODULE/$MAINCLASS \
  --icon $ICON \
  --app-version $VERSION \
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
    $WORKINGDIR/$PROJECT_NAME.app

echo Create DMG ...
jpackage \
  --type dmg \
  --dest $WORKINGDIR \
  --name $PROJECT_NAME \
  --app-image $WORKINGDIR/$PROJECT_NAME.app \
  --icon $ICON \
  --mac-sign \
  --mac-signing-key-user-name "$APPLE_DEV_SIGNING_KEY" \
  --mac-package-identifier $IDENTIFIER \
  --mac-package-name $PROJECT_NAME \
  --mac-entitlements $ENTITLEMENTS \
  --vendor "$VENDOR" \
  --app-version $VERSION \
  --copyright "\$COPYRIGHT"

echo Notarize ...
xcrun \
  notarytool \
  submit \
  --apple-id $APPLE_DEV_ID \
  --team-id $APPLE_DEV_TEAM_ID \
  --password $APPLE_DEV_APP_PASSWORD \
  $WORKINGDIR/$PROJECT_NAME-$VERSION.dmg \
  --wait

echo Staple ...

xcrun \
  stapler \
  staple \
  $WORKINGDIR/$PROJECT_NAME-$VERSION.dmg
