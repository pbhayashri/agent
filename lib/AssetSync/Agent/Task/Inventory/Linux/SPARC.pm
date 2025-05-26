package AssetSync::Agent::Task::Inventory::Linux::SPARC;

use strict;
use warnings;

use parent 'AssetSync::Agent::Task::Inventory::Module';

use Config;

use AssetSync::Agent::Tools;

sub isEnabled {
    my (%params) = @_;

    return Uname("-m") =~ /^sparc/ if $params{remote};
    return $Config{archname} =~ /^sparc/;
};

sub doInventory {
}

1;
