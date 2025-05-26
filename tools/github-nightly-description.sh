#! /bin/bash

set -e

unset HEADER MSI_X86

while [ -n "$1" ]
do
    case "$1" in
        --version|-v)
            shift
            VERSION="$1"
            ;;
        --header)
            HEADER="yes"
            ;;
        --date)
            shift
            DATE="$1"
            ;;
    esac
    shift
done

if [ -z "$VERSION" ]; then
    echo "VERSION not provided" >&2
    exit 1
fi

if [ -z "$DATE" ]; then
    DATE="$( date -u +'%F %H:%M:%S UTC' )"
fi

if [ -n "$HEADER" ]; then
    cat <<HEADER
---
layout: default
title: AssetSync-Agent Nightly Builds
---

HEADER
fi

# Support x86 MSI is still available
if [ -e "assetsync-agent/AssetSync-Agent-$VERSION-x86.msi" -a -e "assetsync-agent/AssetSync-Agent-$VERSION-x86.zip" ]; then
    MSI_X86="32 bits | [AssetSync-Agent-$VERSION-x86.msi](AssetSync-Agent-$VERSION-x86.msi) | [AssetSync-Agent-$VERSION-x86.zip](AssetSync-Agent-$VERSION-x86.zip)"
fi

# Set size for linux installers
LININST="~9M"
if [ -e "assetsync-agent-${VERSION}-linux-installer.pl" ]; then
    read LININST X <<<$(LANG=C ls -sh assetsync-agent-${VERSION}-linux-installer.pl)
fi
LINBIGINST="~41M"
if [ -e "assetsync-agent-${VERSION}-with-snap-linux-installer.pl" ]; then
    read LINBIGINST X <<<$(LANG=C ls -sh assetsync-agent-${VERSION}-with-snap-linux-installer.pl)
fi

cat <<DESCRIPTION
# AssetSync-Agent v$VERSION nightly build

Built on $DATE

## Windows <a href="#windows-${VERSION//./-}">#</a> {#windows-${VERSION//./-}}

Arch | Windows installer | Windows portable archive
---|:---|:---
64 bits | [AssetSync-Agent-$VERSION-x64.msi](AssetSync-Agent-$VERSION-x64.msi) | [AssetSync-Agent-$VERSION-x64.zip](AssetSync-Agent-$VERSION-x64.zip)
$MSI_X86

## MacOSX <a href="#macosx-${VERSION//./-}">#</a> {#macosx-${VERSION//./-}}

### MacOSX - Intel

Arch | Package
---|:---
x86_64 | PKG: [AssetSync-Agent-${VERSION}_x86_64.pkg](AssetSync-Agent-${VERSION}_x86_64.pkg)
x86_64 | DMG: [AssetSync-Agent-${VERSION}_x86_64.dmg](AssetSync-Agent-${VERSION}_x86_64.dmg)

### MacOSX - Apple Silicon

Arch | Package
---|:---
arm64 | PKG: [AssetSync-Agent-${VERSION}_arm64.pkg](AssetSync-Agent-${VERSION}_arm64.pkg)
arm64 | DMG: [AssetSync-Agent-${VERSION}_arm64.dmg](AssetSync-Agent-${VERSION}_arm64.dmg)

## Linux <a href="#linux-${VERSION//./-}">#</a> {#linux-${VERSION//./-}}

### Linux installer

Linux installer for redhat/centos/debian/ubuntu|Size
---|---
[assetsync-agent-${VERSION}-linux-installer.pl](assetsync-agent-${VERSION}-linux-installer.pl)|${LININST}b

<p/>

Linux installer for redhat/centos/debian/ubuntu, including snap install support|Size
---|---
[assetsync-agent-${VERSION}-with-snap-linux-installer.pl](assetsync-agent-${VERSION}-with-snap-linux-installer.pl)|${LINBIGINST}b

### Snap package for amd64

[assetsync-agent_${VERSION}_amd64.snap](assetsync-agent_${VERSION}_amd64.snap)

### AppImage Linux installer for x86-64

[assetsync-agent-${VERSION}-x86_64.AppImage](assetsync-agent-${VERSION}-x86_64.AppImage)

### Debian/Ubuntu packages

Better use [assetsync-agent-${VERSION}-linux-installer.pl](assetsync-agent-${VERSION}-linux-installer.pl) when possible.

Related agent task |Package
---|:---
Inventory| [assetsync-agent_${VERSION}_all.deb](assetsync-agent_${VERSION}_all.deb)
NetInventory | [assetsync-agent-task-network_${VERSION}_all.deb](assetsync-agent-task-network_${VERSION}_all.deb)
ESX | [assetsync-agent-task-esx_${VERSION}_all.deb](assetsync-agent-task-esx_${VERSION}_all.deb)
Collect | [assetsync-agent-task-collect_${VERSION}_all.deb](assetsync-agent-task-collect_${VERSION}_all.deb)
Deploy | [assetsync-agent-task-deploy_${VERSION}_all.deb](assetsync-agent-task-deploy_${VERSION}_all.deb)

### RPM packages

RPM packages are arch independents and installation may require some repository setups, better use [assetsync-agent-${VERSION}-linux-installer.pl](assetsync-agent-${VERSION}-linux-installer.pl) when possible.

Task |Packages
---|:---
Inventory| [assetsync-agent-${VERSION}.noarch.rpm](assetsync-agent-${VERSION}.noarch.rpm)
NetInventory | [assetsync-agent-task-network-${VERSION}.noarch.rpm](assetsync-agent-task-network-${VERSION}.noarch.rpm)
ESX | [assetsync-agent-task-esx-${VERSION}.noarch.rpm](assetsync-agent-task-esx-${VERSION}.noarch.rpm)
Collect | [assetsync-agent-task-collect-${VERSION}.noarch.rpm](assetsync-agent-task-collect-${VERSION}.noarch.rpm)
Deploy | [assetsync-agent-task-deploy-${VERSION}.noarch.rpm](assetsync-agent-task-deploy-${VERSION}.noarch.rpm)
WakeOnLan | [assetsync-agent-task-wakeonlan-${VERSION}.noarch.rpm](assetsync-agent-task-wakeonlan-${VERSION}.noarch.rpm)
Cron | [assetsync-agent-cron-${VERSION}.noarch.rpm](assetsync-agent-cron-${VERSION}.noarch.rpm)

## Sources <a href="#sources-${VERSION//./-}">#</a> {#sources-${VERSION//./-}}

[AssetSync-Agent-${VERSION}.tar.gz](AssetSync-Agent-${VERSION}.tar.gz)

## SHA256 sums
All sha256 sums for released filed can be retrieved from [assetsync-agent-${VERSION}.sha256](assetsync-agent-${VERSION}.sha256).

<p><a href='#content'>Back to top</a></p>
---

DESCRIPTION
