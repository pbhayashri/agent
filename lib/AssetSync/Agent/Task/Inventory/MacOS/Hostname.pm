package AssetSync::Agent::Task::Inventory::MacOS::Hostname;

use strict;
use warnings;

use parent 'AssetSync::Agent::Task::Inventory::Module';

use AssetSync::Agent::Tools;
use AssetSync::Agent::Tools::MacOS;

use constant    category    => "hardware";

sub isEnabled {
    return canRun('/usr/sbin/system_profiler');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $hostname = _getHostname(
        logger => $logger
    );

    $inventory->setHardware({
        NAME => $hostname
    }) if $hostname;
}

sub _getHostname {
    my (%params) = @_;

    my $infos = getSystemProfilerInfos(type => 'SPSoftwareDataType', %params);

    return $infos->{'Software'}->{'System Software Overview'}->{'Computer Name'};
}

1;
