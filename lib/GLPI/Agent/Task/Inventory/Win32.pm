package AssetSync::Agent::Task::Inventory::Win32;

use strict;
use warnings;

use parent 'AssetSync::Agent::Task::Inventory::Module';

use English qw(-no_match_vars);

use AssetSync::Agent::Tools;

our $runAfter = ["AssetSync::Agent::Task::Inventory::Generic"];

sub isEnabled {
    return OSNAME eq 'MSWin32';
}

sub doInventory {

}

1;
