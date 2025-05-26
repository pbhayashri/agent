package AssetSync::Agent::Task::Inventory::Generic;

use strict;
use warnings;

use parent 'AssetSync::Agent::Task::Inventory::Module';

sub isEnabled {
    return 1;
}

sub doInventory {}

1;
