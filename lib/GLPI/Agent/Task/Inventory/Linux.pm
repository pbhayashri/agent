package AssetSync::Agent::Task::Inventory::Linux;

use strict;
use warnings;

use parent 'AssetSync::Agent::Task::Inventory::Module';

use AssetSync::Agent::Tools;

our $runAfter = ["AssetSync::Agent::Task::Inventory::Generic"];

sub isEnabled {
    return OSNAME eq 'linux';
}

sub doInventory {}

1;
