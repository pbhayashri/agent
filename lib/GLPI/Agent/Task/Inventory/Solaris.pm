package AssetSync::Agent::Task::Inventory::Solaris;

use strict;
use warnings;

use parent 'AssetSync::Agent::Task::Inventory::Module';

use AssetSync::Agent::Tools;

our $runAfter = ["AssetSync::Agent::Task::Inventory::Generic"];

sub isEnabled {
    return OSNAME eq 'solaris';
}

sub doInventory {}

1;
