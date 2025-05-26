package AssetSync::Agent::Task::Inventory::Generic::PCI;

use strict;
use warnings;

use parent 'AssetSync::Agent::Task::Inventory::Module';

use AssetSync::Agent::Tools;

sub isEnabled {
    return canRun('lspci');
}

sub doInventory {}

1;
