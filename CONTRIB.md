
# AssetSync Agent Contribs

## Included contribs

 * [Unix](contrib/unix):
   * legacy Redhat init scripts
   * systemd sample service file
   * install-deb.sh by @J-C-P, script to simplify installation on debian/ubuntu, see [README](contrib/unix/install-deb-README.md)
 * [Windows](contrib/windows):
   * [assetsync-agent-deployment.vbs](contrib/windows/assetsync-agent-deployment.vbs):
     AssetSync Agent deployment helper script
   * ADML & ADMX templates to help setup AssetSync Agent through GPO
 * [netdisco_2_AssetSync.sh](contrib/netdisco/netdisco_2_AssetSync.sh) by Stoatwblr
   This script makes fusioninventory-compatible xml from netdisco data.
   Stoatwblr says even if it is ugly and slow, it works ;-)

## Other contribs

 * Windows:
   * [AssetSync-Agent Monitor](https://github.com/glpi-project/glpi-agentmonitor):
     Little tool developed by @redddcyclone which provides a systray icon to monitor assetsync-agent service status
     and permits to request assetsync-agent to run its tasks.

## Submit your contribs

 * Clone [AssetSync-Agent github repository](https://github.com/glpi-project/glpi-agent)
 * Create a dedicated branch to develop and test your contrib
 * On your develop branch, update this CONTRIB.md file to reference properly your contrib
 * Make a PR so we only include your new contrib reference
