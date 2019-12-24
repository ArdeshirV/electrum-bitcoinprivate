#!/usr/bin/env python3

# python setup.py sdist --format=zip,gztar

from setuptools import setup
import os
import sys
import platform
import imp
import argparse

with open('contrib/requirements/requirements.txt') as f:
    requirements = f.read().splitlines()

with open('contrib/requirements/requirements-hw.txt') as f:
    requirements_hw = f.read().splitlines()

version = imp.load_source('version', 'lib/version.py')

if sys.version_info[:3] < (3, 4, 0):
    sys.exit("Error: Electrum-bitcoinprivate requires Python version >= 3.4.0...")

data_files = []

if platform.system() in ['Linux', 'FreeBSD', 'DragonFly']:
    parser = argparse.ArgumentParser()
    parser.add_argument('--root=', dest='root_path', metavar='dir', default='/')
    opts, _ = parser.parse_known_args(sys.argv[1:])
    usr_share = os.path.join(sys.prefix, "share")
    icons_dirname = 'pixmaps'
    if not os.access(opts.root_path + usr_share, os.W_OK) and \
       not os.access(opts.root_path, os.W_OK):
        icons_dirname = 'icons'
        if 'XDG_DATA_HOME' in os.environ.keys():
            usr_share = os.environ['XDG_DATA_HOME']
        else:
            usr_share = os.path.expanduser('~/.local/share')
    data_files += [
        (os.path.join(usr_share, 'applications/'), ['electrum-bitcoinprivate.desktop']),
        (os.path.join(usr_share, icons_dirname), ['icons/electrum-bitcoinprivate.png'])
    ]

setup(
    name="Electrum-bitcoinprivate",
    version=version.ELECTRUM_VERSION,
    install_requires=requirements,
    extras_require={
        'full': requirements_hw + ['pycryptodomex'],
    },
    packages=[
        'electrum_bitcoinprivate',
        'electrum_bitcoinprivate_gui',
        'electrum_bitcoinprivate_gui.qt',
        'electrum_bitcoinprivate_plugins',
        'electrum_bitcoinprivate_plugins.audio_modem',
        'electrum_bitcoinprivate_plugins.cosigner_pool',
        'electrum_bitcoinprivate_plugins.email_requests',
        'electrum_bitcoinprivate_plugins.hw_wallet',
        'electrum_bitcoinprivate_plugins.keepkey',
        'electrum_bitcoinprivate_plugins.labels',
        'electrum_bitcoinprivate_plugins.ledger',
        'electrum_bitcoinprivate_plugins.trezor',
        'electrum_bitcoinprivate_plugins.digitalbitbox',
        'electrum_bitcoinprivate_plugins.virtualkeyboard',
    ],
    package_dir={
        'electrum_bitcoinprivate': 'lib',
        'electrum_bitcoinprivate_gui': 'gui',
        'electrum_bitcoinprivate_plugins': 'plugins',
    },
    package_data={
        'electrum_bitcoinprivate': [
            'servers.json',
            'servers_testnet.json',
            'servers_regtest.json',
            'currencies.json',
            'wordlist/*.txt',
            'locale/*/LC_MESSAGES/electrum.mo',
        ]
    },
    scripts=['electrum-bitcoinprivate'],
    data_files=data_files,
    description="Lightweight bitcoinprivate Wallet",
    author="Thomas Voegtlin",
    author_email="thomasv@electrum.org",
    license="MIT License",
    url="https://github.com/BTCPrivate/electrum-bitcoinprivate",
    long_description="""Lightweight bitcoinprivate Wallet"""
)
