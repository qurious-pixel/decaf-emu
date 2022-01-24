#!/bin/bash -ex

BRANCH=`echo ${GITHUB_REF##*/}`
BINARY=decaf-emu
        QT_BASE_DIR=${GITHUB_WORKSPACE}/${{ env.Qt6_DIR }}/gcc_64
        export QTDIR=$QT_BASE_DIR
        export PATH=$QT_BASE_DIR/bin:$PATH
        export LD_LIBRARY_PATH=$QT_BASE_DIR/lib:$LD_LIBRARY_PATH

mkdir -p AppDir/usr/bin
cp build/install/bin/decaf-qt AppDir/usr/bin/"$BINARY"
cp -r build/install/share/decaf-emu/resources AppDir/usr/
cp .github/workflows/"$BINARY".png AppDir/"$BINARY".png
cp .github/workflows/"$BINARY".desktop AppDir/"$BINARY".desktop
#cp AppDir/update.sh
cp .github/workflows/AppRun AppDir/AppRun
cp .github/workflows/config.toml.app AppDir/usr/resources
curl -sL https://github.com/AppImage/AppImageKit/releases/download/continuous/AppRun-x86_64 -o AppDir/AppRun.wrapped
curl -sL https://github.com/AppImage/AppImageKit/releases/download/continuous/runtime-x86_64 -o ./AppDir/runtime
mkdir -p AppDir/usr/share/applications && cp ./AppDir/"$BINARY".desktop ./AppDir/usr/share/applications
mkdir -p AppDir/usr/share/icons && cp ./AppDir/"$BINARY".png ./AppDir/usr/share/icons
mkdir -p AppDir/usr/share/icons/hicolor/scalable/apps && cp ./AppDir/"$BINARY".png ./AppDir/usr/share/icons/hicolor/scalable/apps
mkdir -p AppDir/usr/share/pixmaps && cp ./AppDir/"$BINARY".png ./AppDir/usr/share/pixmaps
#mkdir -p AppDir/usr/optional/ ; mkdir -p AppDir/usr/optional/libstdc++/
#mkdir -p AppDir/usr/share/zenity 
#cp /usr/share/zenity/zenity.ui ./AppDir/usr/share/zenity/
#cp /usr/bin/zenity ./AppDir/usr/bin/
#cp /usr/bin/realpath ./AppDir/usr/bin/

#curl -sL https://github.com/RPCS3/AppImageKit-checkrt/releases/download/continuous2/exec-x86_64.so -o ./AppDir/usr/optional/exec.so
#cp /usr/lib/x86_64-linux-gnu/libstdc++.so.6 AppDir/usr/optional/libstdc++/

chmod a+x ./AppDir/AppRun
chmod a+x ./AppDir/AppRun.wrapped
chmod a+x ./AppDir/runtime
chmod a+x ./AppDir/usr/bin/"$BINARY"
#chmod a+x ./AppDir/update.sh

#curl -sLO https://raw.githubusercontent.com/$GITHUB_REPOSITORY/$BRANCH/.travis/update.tar.gz
#tar -xzf update.tar.gz
#mv update/AppImageUpdate ./AppDir/usr/bin/
mkdir -p AppDir/usr/lib/
#mv update/* ./AppDir/usr/lib/
sudo cp /usr/lib/x86_64-linux-gnu/libgio-2.0.so.0 ./AppDir/usr/lib/

echo $name > ./AppDir/version.txt


ls -al ./AppDir

#wget "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
#chmod a+x appimagetool-x86_64.AppImage
#./appimagetool-x86_64.AppImage AppDir/ -u "gh-releases-zsync|qurious-pixel|"$BINARY"|continuous|"$BINARY"-x86_64.AppImage.zsync"

#export LD_LIBRARY_PATH=/opt/qt${QTVERMIN}/lib:${LD_LIBRARY_PATH}
#export PATH=$HOME/.local/bin:/opt/qt${QTVERMIN}/bin:${PATH}

curl -sSLO https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
curl -sSLO https://github.com/linuxdeploy/linuxdeploy-plugin-appimage/releases/download/continuous/linuxdeploy-plugin-appimage-x86_64.AppImage
curl -sSLO https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage
chmod a+x linuxdeploy-x86_64.AppImage
chmod a+x linuxdeploy-plugin-appimage-x86_64.AppImage
chmod a+x linuxdeploy-plugin-qt-x86_64.AppImage

./linuxdeploy-x86_64.AppImage --appimage-extract
mv ./squashfs-root/usr/bin/patchelf ./squashfs-root/usr/bin/patchelf.orig
sudo cp /usr/local/bin/patchelf ./squashfs-root/usr/bin/patchelf

export UPDATE_INFORMATION="gh-releases-zsync|qurious-pixel|$BINARY|continuous|$BINARY-x86_64.AppImage.zsync"
export OUTPUT="$BINARY-x86_64.AppImage"
"$GITHUB_WORKSPACE"/squashfs-root/AppRun \
  --appdir="$GITHUB_WORKSPACE"/AppDir \
  --executable="$GITHUB_WORKSPACE"/AppDir/usr/bin/"$BINARY" \
  --desktop-file="$GITHUB_WORKSPACE"/AppDir/"$BINARY".desktop \
  --icon-file="$GITHUB_WORKSPACE"/AppDir/"$BINARY".png \
  --output=appimage \
  --plugin=qt

mkdir artifacts
mv "$BINARY"-x86_64.AppImage* artifacts
