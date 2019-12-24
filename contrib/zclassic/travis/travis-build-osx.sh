#!/bin/bash
set -ev

if [[ -z $TRAVIS_TAG ]]; then
  echo TRAVIS_TAG unset, exiting
  exit 1
fi

BUILD_REPO_URL=https://github.com/BTCPrivate/electrum-bitcoinprivate

cd build

git clone --branch $TRAVIS_TAG $BUILD_REPO_URL electrum-bitcoinprivate

cd electrum-bitcoinprivate

export PY36BINDIR=/Library/Frameworks/Python.framework/Versions/3.6/bin/
export PATH=$PATH:$PY36BINDIR
source ./contrib/bitcoinprivate/travis/electrum_bitcoinprivate_version_env.sh;
echo wine build version is $ELECTRUM_BTCP_VERSION

sudo pip3 install --upgrade pip
sudo pip3 install -r contrib/deterministic-build/requirements.txt
sudo pip3 install \
    pycryptodomex==3.6.0 \
    btchip-python==0.1.28 \
    keepkey==4.0.2 \
    trezor==0.9.1

pyrcc5 icons.qrc -o gui/qt/icons_rc.py

export PATH="/usr/local/opt/gettext/bin:$PATH"
./contrib/make_locale
find . -name '*.po' -delete
find . -name '*.pot' -delete

cp contrib/bitcoinprivate/osx.spec .
cp contrib/bitcoinprivate/pyi_runtimehook.py .
cp contrib/bitcoinprivate/pyi_tctl_runtimehook.py .

pyinstaller \
    -y \
    --name electrum-bitcoinprivate-$ELECTRUM_BTCP_VERSION.bin \
    osx.spec

sudo hdiutil create -fs HFS+ -volname "Electrum-bitcoinprivate" \
    -srcfolder dist/Electrum-bitcoinprivate.app \
    dist/electrum-bitcoinprivate-$ELECTRUM_BTCP_VERSION-macosx.dmg
