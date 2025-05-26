package AssetSync::Agent::Task::Inventory::Generic::Ipmi::Fru;

use strict;
use warnings;

use parent 'AssetSync::Agent::Task::Inventory::Module';

use AssetSync::Agent::Tools;

sub isEnabled {
    return canRun('ipmitool');
}

sub doInventory {}

1;
