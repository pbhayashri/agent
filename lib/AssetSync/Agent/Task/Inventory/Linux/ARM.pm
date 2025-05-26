package AssetSync::Agent::Task::Inventory::Linux::ARM;

use strict;
use warnings;

use parent 'AssetSync::Agent::Task::Inventory::Module';

use Config;

use AssetSync::Agent::Tools;

sub isEnabled {
    my (%params) = @_;

    return Uname("-m") =~ /^(arm|aarch64)/ if $params{remote};
    return $Config{archname} =~ /^(arm|aarch64)/;
}

sub doInventory {
}

1;
