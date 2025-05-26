package
    InstallerVersion;

# Support assetsync-agent-linux-installer.pl run from sources for testing
use lib qw(./lib ../../lib);

use AssetSync::Agent::Version;
use constant DISTRO  => "linux";

sub VERSION {
    return $AssetSync::Agent::Version::VERSION;
}

1;
