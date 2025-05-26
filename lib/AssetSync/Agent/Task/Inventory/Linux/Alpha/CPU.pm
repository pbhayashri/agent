package AssetSync::Agent::Task::Inventory::Linux::Alpha::CPU;

use strict;
use warnings;

use parent 'AssetSync::Agent::Task::Inventory::Module';

use AssetSync::Agent::Tools;
use AssetSync::Agent::Tools::Linux;

use constant    category    => "cpu";

sub isEnabled {
    return canRead('/proc/cpuinfo');
};

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $cpu (_getCPUsFromProc(
        logger => $logger, file => '/proc/cpuinfo')
    ) {
        $inventory->addEntry(
            section => 'CPUS',
            entry   => $cpu
        );
    }
}

sub _getCPUsFromProc {
    my @cpus;
    foreach my $cpu (getCPUsFromProc(@_)) {

        my $speed;
        if (
            $cpu->{'cycle frequency [hz]'} &&
            $cpu->{'cycle frequency [hz]'} =~ /(\d+)000000/
        ) {
            $speed = $1;
        }

        push @cpus, {
            ARCH   => 'alpha',
            NAME   => $cpu->{processor},
            SERIAL => $cpu->{'cpu serial number'},
            SPEED  => $speed
        };
    }

    return @cpus;
}

1;
