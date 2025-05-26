package AssetSync::Agent::Task::Inventory::MacOS::Psu;

use strict;
use warnings;

use parent 'AssetSync::Agent::Task::Inventory::Module';

use AssetSync::Agent::Tools;
use AssetSync::Agent::Tools::MacOS;
use AssetSync::Agent::Tools::PowerSupplies;

use constant    category    => "psu";

our $runAfterIfEnabled = [ qw(
    AssetSync::Agent::Task::Inventory::Generic::Dmidecode::Psu
)];

sub isEnabled {
    return canRun('/usr/sbin/system_profiler');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $charger = _getCharger(logger => $logger)
        or return;

    # Empty current POWERSUPPLIES section into a new psu list
    my $psulist = Inventory::PowerSupplies->new( logger => $logger );
    my $section = $inventory->getSection('POWERSUPPLIES') || [];
    while (@{$section}) {
        my $powersupply = shift @{$section};
        $psulist->add($powersupply);
    }

    $psulist->merge($charger);

    # Add back merged powersupplies into inventory
    foreach my $psu ($psulist->list()) {
        $inventory->addEntry(
            section => 'POWERSUPPLIES',
            entry   => $psu
        );
    }
}

sub _getCharger {
    my (%params) = @_;

    my $infos = AssetSync::Agent::Tools::MacOS::getSystemProfilerInfos(
        type    => 'SPPowerDataType',
        format  => 'text',
        %params
    );

    return unless $infos->{Power};

    my $infoPower = $infos->{Power}->{'AC Charger Information'}
        or return;

    my $charger = {
        SERIALNUMBER    => $infoPower->{'Serial Number'},
        NAME            => $infoPower->{'Name'},
        MANUFACTURER    => $infoPower->{'Manufacturer'},
        STATUS          => $infoPower->{'Charging'} && $infoPower->{'Charging'} eq "Yes" ? "Charging" : "Not charging",
        PLUGGED         => $infoPower->{'Connected'} // "No",
        POWER_MAX       => $infoPower->{'Wattage (W)'},
    };

    return $charger;
}

1;
