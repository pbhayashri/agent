package AssetSync::Agent::Task::Inventory::Generic::Remote_Mgmt;

use strict;
use warnings;

use parent 'AssetSync::Agent::Task::Inventory::Module';

use constant    category    => "remote_mgmt";

sub isEnabled {
    return 1;
}

sub doInventory {
}

1;
