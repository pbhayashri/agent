package AssetSync::Agent::Task::Inventory::Generic::Firewall;

use strict;
use warnings;

use parent 'AssetSync::Agent::Task::Inventory::Module';

use constant    category    => "firewall";

sub isEnabled {
    return 1;
}

sub doInventory {}

1;
