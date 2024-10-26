#######################################################################################################################
# Settings
#######################################################################################################################

Set-Variable -Name REPO -Value C:\Home\Development\M2-Repository

Set-Variable -Name WORKINGDIR -Value "target"
Set-Variable -Name SOURCEDIR -Value "../../"


Set-Variable -Name PUBLIC_NAME -Value FxHelloWorld
Set-Variable -Name PUBLIC_VERSION -Value "1.0"

Set-Variable -Name MAIN_MODULE -Value fxhelloworld
Set-Variable -Name MAIN_CLASS -Value ch.nostromo.fxhelloworld.FxHelloWorld
Set-Variable -NAME ARTIFACT -Value "ch\nostromo\fxhelloworld\1.0.0\fxhelloworld-1.0.0.jar"

Set-Variable -Name UUID -Value "17d0c55b-35a7-4f1e-8a61-5e73a5e48b86"

Set-Variable -Name EXTERNAL_MODULES -Value @(
 "$REPO\$ARTIFACT"
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
& jlink.exe --module-path $MODPATH --add-modules $MAIN_MODULE --add-modules jdk.crypto.ec --launcher $PUBLIC_NAME=$MAIN_MODULE/$MAIN_CLASS --output app-vmimage

Write-Output "App image ..."
& jpackage.exe --type app-image --name $PUBLIC_NAME --module $MAIN_MODULE/$MAIN_CLASS --runtime-image app-vmimage

Write-Output "Installer ..."
& jpackage.exe --type msi --name $PUBLIC_NAME --app-version $PUBLIC_VERSION --win-shortcut --win-menu --win-upgrade-uuid $UUID --module-path $MODPATH --module $MAIN_MODULE/$MAIN_CLASS 

cd $STARTDIR
