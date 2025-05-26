package AssetSync::Agent::Task::Inventory::Generic::Arch;

use strict;
use warnings;

use parent 'AssetSync::Agent::Task::Inventory::Module';

use AssetSync::Agent::Tools;

use constant    category    => "os";

sub isEnabled {
    return canRun('arch');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $arch = getFirstLine( command => 'arch' );

    $inventory->setOperatingSystem({
        ARCH     => $arch
    });

}

1;
