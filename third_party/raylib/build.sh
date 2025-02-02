#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $DIR

RAYLIB_PLATFORM="PLATFORM_DESKTOP"

ARCHNAME=$(uname -m)
if [ -f /TICI ]; then
  ARCHNAME="larch64"
  RAYLIB_PLATFORM="PLATFORM_COMMA"
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
  ARCHNAME="Darwin"
fi

INSTALL_DIR="$DIR/$ARCHNAME"
rm -rf $INSTALL_DIR
mkdir -p $INSTALL_DIR

INSTALL_H_DIR="$DIR/include"
rm -rf $INSTALL_H_DIR
mkdir -p $INSTALL_H_DIR

if [ ! -d raylib_repo ]; then
  git clone -b master --no-tags https://github.com/commaai/raylib.git raylib_repo
fi

cd raylib_repo

COMMIT="f5b0a7237c6e45f0e8a6ff68322d19b49298d798"
git fetch origin $COMMIT
git reset --hard $COMMIT
git clean -xdff .

cd src

make -j$(nproc) PLATFORM=$RAYLIB_PLATFORM RAYLIB_RELEASE_PATH=$INSTALL_DIR
cp raylib.h raymath.h rlgl.h $INSTALL_H_DIR/
echo "raylib development files installed/updated in $INSTALL_H_DIR"

# this commit needs to be in line with raylib
set -x
RAYGUI_COMMIT="76b36b597edb70ffaf96f046076adc20d67e7827"
curl -fsSLo $INSTALL_H_DIR/raygui.h https://raw.githubusercontent.com/raysan5/raygui/$RAYGUI_COMMIT/src/raygui.h
