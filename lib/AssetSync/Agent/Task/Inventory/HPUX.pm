package AssetSync::Agent::Task::Inventory::HPUX;

use strict;
use warnings;

use parent 'AssetSync::Agent::Task::Inventory::Module';

use AssetSync::Agent::Tools;

our $runAfter = ["AssetSync::Agent::Task::Inventory::Generic"];

sub isEnabled  {
    return OSNAME eq 'hpux';
}

sub doInventory {}

1;
