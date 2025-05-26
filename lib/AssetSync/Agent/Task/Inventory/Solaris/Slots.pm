package AssetSync::Agent::Task::Inventory::Solaris::Slots;

use strict;
use warnings;

use parent 'AssetSync::Agent::Task::Inventory::Module';

use AssetSync::Agent::Tools;
use AssetSync::Agent::Tools::Solaris;

use constant    category    => "slot";

sub isEnabled {
    return canRun('prtdiag');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $slot (_getSlots(logger => $logger)) {
        $inventory->addEntry(
            section => 'SLOTS',
            entry   => $slot
        );
    }
}

sub _getSlots {
    my $info = getPrtdiagInfos(@_);

    return $info->{slots} ? @{$info->{slots}} : ();
}

1;
