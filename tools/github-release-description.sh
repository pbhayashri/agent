#! /bin/bash

set -e

TAG="${GITHUB_REF#*refs/tags/}"
VERSION="$TAG"

: ${REPO:=https://github.com/glpi-project/glpi-agent}

while [ -n "$1" ]
do
    case "$1" in
        --version|-v)
            shift
            VERSION="$1"
            ;;
        --tag|-t)
            shift
            TAG="$1"
            ;;
    esac
    shift
done

if [ -z "$TAG" -o "$TAG" == "$GITHUB_REF" ]; then
    echo "GITHUB_REF is not referecing a tag" >&2
    exit 1
fi

if [ "${TAG#*-}" == "$TAG" ]; then
    DEBREV="-1"
    RPMREV="-1"
fi

cat >release-description.md <<DESCRIPTION
Here you can download AssetSync-Agent v$VERSION packages.

Don't forget to follow our [installation documentation](https://assetsync-agent.readthedocs.io/en/latest/installation/).

## Windows
Arch | Windows installer | Windows portable archive
---|:---|:---
64 bits | [AssetSync-Agent-$VERSION-x64.msi]($REPO/releases/download/$TAG/AssetSync-Agent-$VERSION-x64.msi) | [AssetSync-Agent-$VERSION-x64.zip]($REPO/releases/download/$TAG/AssetSync-Agent-$VERSION-x64.zip)

## MacOSX

### MacOSX - Intel
Arch | Package
---|:---
x86_64 | PKG: [AssetSync-Agent-${VERSION}_x86_64.pkg]($REPO/releases/download/$TAG/AssetSync-Agent-${VERSION}_x86_64.pkg)
x86_64 | DMG: [AssetSync-Agent-${VERSION}_x86_64.dmg]($REPO/releases/download/$TAG/AssetSync-Agent-${VERSION}_x86_64.dmg)

### MacOSX - Apple Silicon
Arch | Package
---|:---
arm64 | PKG: [AssetSync-Agent-${VERSION}_arm64.pkg]($REPO/releases/download/$TAG/AssetSync-Agent-${VERSION}_arm64.pkg)
arm64 | DMG: [AssetSync-Agent-${VERSION}_arm64.dmg]($REPO/releases/download/$TAG/AssetSync-Agent-${VERSION}_arm64.dmg)

## Linux

### Linux installer
Linux installer for redhat/centos/debian/ubuntu|Size
---|---
[assetsync-agent-${VERSION}-linux-installer.pl]($REPO/releases/download/$TAG/assetsync-agent-${VERSION}-linux-installer.pl)|~9Mb

Linux installer for redhat/centos/debian/ubuntu with also snap install support|Size
---|---
[assetsync-agent-${VERSION}-with-snap-linux-installer.pl]($REPO/releases/download/$TAG/assetsync-agent-${VERSION}-with-snap-linux-installer.pl)|~41Mb

### Snap package for amd64
[assetsync-agent_${VERSION}_amd64.snap]($REPO/releases/download/$TAG/assetsync-agent_${VERSION}_amd64.snap)

### AppImage Linux installer for x86-64
[assetsync-agent-${VERSION}-x86_64.AppImage]($REPO/releases/download/$TAG/assetsync-agent-${VERSION}-x86_64.AppImage)

### Debian/Ubuntu packages
Better use [assetsync-agent-${VERSION}-linux-installer.pl]($REPO/releases/download/$TAG/assetsync-agent-${VERSION}-linux-installer.pl) when possible.
Related agent task |Package
---|:---
Inventory| [assetsync-agent_${VERSION}${DEBREV}_all.deb]($REPO/releases/download/$TAG/assetsync-agent_${VERSION}${DEBREV}_all.deb)
NetInventory | [assetsync-agent-task-network_${VERSION}${DEBREV}_all.deb]($REPO/releases/download/$TAG/assetsync-agent-task-network_${VERSION}${DEBREV}_all.deb)
ESX | [assetsync-agent-task-esx_${VERSION}${DEBREV}_all.deb]($REPO/releases/download/$TAG/assetsync-agent-task-esx_${VERSION}${DEBREV}_all.deb)
Collect | [assetsync-agent-task-collect_${VERSION}${DEBREV}_all.deb]($REPO/releases/download/$TAG/assetsync-agent-task-collect_${VERSION}${DEBREV}_all.deb)
Deploy | [assetsync-agent-task-deploy_${VERSION}${DEBREV}_all.deb]($REPO/releases/download/$TAG/assetsync-agent-task-deploy_${VERSION}${DEBREV}_all.deb)

### RPM packages
RPM packages are arch independents and installation may require some repository setups, better use [assetsync-agent-${VERSION}-linux-installer.pl]($REPO/releases/download/$TAG/assetsync-agent-${VERSION}-linux-installer.pl) when possible.
Task |Packages
---|:---
Inventory| [assetsync-agent-${VERSION}${RPMREV}.noarch.rpm]($REPO/releases/download/$TAG/assetsync-agent-${VERSION}${RPMREV}.noarch.rpm)
NetInventory | [assetsync-agent-task-network-${VERSION}${RPMREV}.noarch.rpm]($REPO/releases/download/$TAG/assetsync-agent-task-network-${VERSION}${RPMREV}.noarch.rpm)
ESX | [assetsync-agent-task-esx-${VERSION}${RPMREV}.noarch.rpm]($REPO/releases/download/$TAG/assetsync-agent-task-esx-${VERSION}${RPMREV}.noarch.rpm)
Collect | [assetsync-agent-task-collect-${VERSION}${RPMREV}.noarch.rpm]($REPO/releases/download/$TAG/assetsync-agent-task-collect-${VERSION}${RPMREV}.noarch.rpm)
Deploy | [assetsync-agent-task-deploy-${VERSION}${RPMREV}.noarch.rpm]($REPO/releases/download/$TAG/assetsync-agent-task-deploy-${VERSION}${RPMREV}.noarch.rpm)
WakeOnLan | [assetsync-agent-task-wakeonlan-${VERSION}${RPMREV}.noarch.rpm]($REPO/releases/download/$TAG/assetsync-agent-task-wakeonlan-${VERSION}${RPMREV}.noarch.rpm)
Cron | [assetsync-agent-cron-${VERSION}${RPMREV}.noarch.rpm]($REPO/releases/download/$TAG/assetsync-agent-cron-${VERSION}${RPMREV}.noarch.rpm)

## Sources
[AssetSync-Agent-${VERSION}.tar.gz]($REPO/releases/download/$TAG/AssetSync-Agent-${VERSION}.tar.gz)

## SHA256 sums
All sha256 sums for released filed can be retrieved from [assetsync-agent-${VERSION}.sha256]($REPO/releases/download/$TAG/assetsync-agent-${VERSION}.sha256).

DESCRIPTION
