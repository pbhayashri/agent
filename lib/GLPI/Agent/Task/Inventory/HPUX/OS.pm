package AssetSync::Agent::Task::Inventory::HPUX::OS;

use strict;
use warnings;

use parent 'AssetSync::Agent::Task::Inventory::Module';

use AssetSync::Agent::Tools;

use constant    category    => "os";

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    # Operating system informations
    my $kernelRelease = Uname("-r");

    my $os = {
        NAME           => 'HP-UX',
        VERSION        => $kernelRelease,
        KERNEL_VERSION => $kernelRelease,
    };

    my $installdate = getRootFSBirth(%params);
    $os->{INSTALL_DATE} = $installdate
        if $installdate;

    $inventory->setOperatingSystem($os);
}

1;
