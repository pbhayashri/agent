package AssetSync::Agent::Task::Inventory::BSD;

use strict;
use warnings;

use parent 'AssetSync::Agent::Task::Inventory::Module';

use AssetSync::Agent::Tools;

our $runAfter = ["AssetSync::Agent::Task::Inventory::Generic"];

sub isEnabled {
    return OSNAME =~ /freebsd|openbsd|netbsd|gnukfreebsd|gnuknetbsd|dragonfly/;
}

sub doInventory {}

1;
