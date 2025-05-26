package AssetSync::Agent::Task::Inventory::Generic::Ipmi::Fru::Controllers;

use strict;
use warnings;

use parent 'AssetSync::Agent::Task::Inventory::Module';

use AssetSync::Agent::Tools;
use AssetSync::Agent::Tools::IpmiFru;

use constant    category    => "controller";

my $CONTROLLERS = qr/^(?:
    BP               |
    PERC             |
    NDC              |
    Ethernet\s+Adptr |
    SAS\s+Ctlr
)\d*\s+/x;

sub isEnabled {
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my $fru = getIpmiFru(%params)
        or return;

    my @fru_keys = grep { $_ =~ $CONTROLLERS } keys %$fru
        or return;

    my $fields = $inventory->getFields()->{CONTROLLERS};
    for my $descr (@fru_keys) {
        my $ctrl = parseFru($fru->{$descr}, $fields);
        next unless keys %$ctrl;

        $ctrl->{TYPE} = $1 if $descr =~ /^([\w\s]+[[:alpha:]])/;

        $inventory->addEntry(
            section => 'CONTROLLERS',
            entry   => $ctrl
        );
    }
}

1;
