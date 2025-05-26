package AssetSync::Agent::Task::Inventory::Generic::Processes;

use strict;
use warnings;

use parent 'AssetSync::Agent::Task::Inventory::Module';

use AssetSync::Agent::Tools;
use AssetSync::Agent::Tools::Unix;

use constant    category    => "process";

sub isEnabled {
    return
        OSNAME ne 'MSWin32' &&
        canRun('ps');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $process (getProcesses(logger => $logger)) {
        $inventory->addEntry(
            section => 'PROCESSES',
            entry   => $process
        );
    }
}

1;
