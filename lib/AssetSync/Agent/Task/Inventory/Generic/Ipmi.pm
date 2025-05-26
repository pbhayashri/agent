package AssetSync::Agent::Task::Inventory::Generic::Ipmi;

use strict;
use warnings;

use parent 'AssetSync::Agent::Task::Inventory::Module';

use AssetSync::Agent::Tools;

sub isEnabled {
    return unless canRun('ipmitool');
}

sub doInventory {}

1;
