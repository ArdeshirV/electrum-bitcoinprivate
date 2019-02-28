#!/bin/bash

source ./contrib/zclassic/travis/electrum_zclassic_version_env.sh;
echo wine build version is $ELECTRUM_ZCL_VERSION

mv /opt/zbarw $WINEPREFIX/drive_c/
cd $WINEPREFIX/drive_c/electrum-zclassic

rm -rf build
rm -rf dist/electrum-zclassic

cp contrib/zclassic/deterministic.spec .
cp contrib/zclassic/pyi_runtimehook.py .
cp contrib/zclassic/pyi_tctl_runtimehook.py .

wine pip install --upgrade pip
export PYINSTALLER_TAG=dev180610
wget https://github.com/zebra-lucky/pyinstaller/archive/$PYINSTALLER_TAG.tar.gz
wine pip install $PYINSTALLER_TAG.tar.gz
rm $PYINSTALLER_TAG.tar.gz

wine pip install eth-hash==0.1.2
wine pip install -r contrib/zclassic/requirements.txt

wine pip install x11_hash
wine pip install cython
wine pip install hidapi
wine pip install pycryptodomex==3.6.0
wine pip install btchip-python==0.1.26
wine pip install keepkey==4.0.2
wine pip install trezor==0.9.1

mkdir $WINEPREFIX/drive_c/Qt
ln -s $PYHOME/Lib/site-packages/PyQt5/ $WINEPREFIX/drive_c/Qt/5.5.1

wine pyinstaller -y \
    --name electrum-zclassic-$ELECTRUM_ZCL_VERSION.exe \
    deterministic.spec

if [[ $WINEARCH == win32 ]]; then
    NSIS_EXE="$WINEPREFIX/drive_c/Program Files/NSIS/makensis.exe"
else
    NSIS_EXE="$WINEPREFIX/drive_c/Program Files (x86)/NSIS/makensis.exe"
fi

wine "$NSIS_EXE" /NOCD -V3 \
    /DPRODUCT_VERSION=$ELECTRUM_ZCL_VERSION \
    /DWINEARCH=$WINEARCH \
    contrib/zclassic/electrum-zclassic.nsi
