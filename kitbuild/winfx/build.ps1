#######################################################################################################################
# Settings
#######################################################################################################################

Set-Variable -Name REPO -Value C:\Home\Development\M2-Repository

Set-Variable -Name WORKINGDIR -Value "target"
Set-Variable -Name SOURCEDIR -Value "../../"

Set-Variable -Name PROJECT_NAME -Value FxHelloWorld
Set-Variable -Name ARTIFACT_VERSION -Value "1.0.0"
Set-Variable -Name PUBLICVERSION -Value "1.0"
Set-Variable -Name MAINMODULE -Value fxhelloworld
Set-Variable -Name MAINCLASS -Value ch.nostromo.fxhelloworld.FxHelloWorld
Set-Variable -Name MAINJAR -Value fxhelloworld-$ARTIFACT_VERSION.jar

Set-Variable -Name UUID -Value "17d0c55b-35a7-4f1e-8a61-5e73a5e48b86"

Set-Variable -Name EXTERNAL_MODULES -Value @(
 "$REPO\ch\nostromo\fxhelloworld\$ARTIFACT_VERSION\$MAINJAR"
 "$REPO\org\openjfx\javafx-base\17.0.13\javafx-base-17.0.13-win.jar"
 "$REPO\org\openjfx\javafx-controls\17.0.13\javafx-controls-17.0.13-win.jar"
 "$REPO\org\openjfx\javafx-fxml\17.0.13\javafx-fxml-17.0.13-win.jar"
 "$REPO\org\openjfx\javafx-graphics\17.0.13\javafx-graphics-17.0.13-win.jar"
 "$REPO\org\openjfx\javafx-media\17.0.13\javafx-media-17.0.13-win.jar"
 "$REPO\org\openjfx\javafx-web\17.0.13\javafx-web-17.0.13-win.jar"
)

Set-Variable -Name MODPATH -Value target
ForEach ($i in $EXTERNAL_MODULES) {
   $MODPATH += ";"
   $MODPATH += $i
}

#######################################################################################################################
# Running Build
#######################################################################################################################

$STARTDIR = pwd | Select-Object | %{$_.ProviderPath}

if (Test-Path $WORKINGDIR) { 
  Remove-Item $WORKINGDIR -Recurse -force; 
}
new-item $WORKINGDIR -itemtype directory > $null

cd $WORKINGDIR

Write-Output "Jlink ..."
& jlink.exe --module-path $MODPATH --add-modules $MAINMODULE --add-modules jdk.crypto.ec --launcher $PROJECT_NAME=$MAINMODULE/$MAINCLASS --output app-vmimage

Write-Output "App image ..."
& jpackage.exe --type app-image --name $PROJECT_NAME --module $MAINMODULE/$MAINCLASS --runtime-image app-vmimage

Write-Output "Installer ..."
& jpackage.exe --type msi --name $PROJECT_NAME --app-version $PUBLICVERSION --win-shortcut --win-menu --win-upgrade-uuid $UUID --module-path $MODPATH --module $MAINMODULE/$MAINCLASS 

cd $STARTDIR
