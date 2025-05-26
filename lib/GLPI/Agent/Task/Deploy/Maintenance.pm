package AssetSync::Agent::Task::Deploy::Maintenance;

use strict;
use warnings;

use AssetSync::Agent::Logger;
use AssetSync::Agent::Storage;
use AssetSync::Agent::Task::Deploy::Datastore;

sub new {
    my ($class, %params) = @_;

    die 'no target parameter\n' unless $params{target};
    die 'no config parameter\n' unless $params{config};

    my $self = {
        logger       => $params{logger} ||
                        AssetSync::Agent::Logger->new(),
        config       => $params{config},
        target       => $params{target},
    };
    bless $self, $class;

    return $self;
}

sub doMaintenance {
    my ($self) = @_;

    my $folder = $self->{target}->getStorage()->getDirectory()
        or return;

    $folder .= '/deploy';
    return unless -d $folder;

    my $datastore = AssetSync::Agent::Task::Deploy::Datastore->new(
        config => $self->{config},
        path   => $folder,
        logger => $self->{logger}
    );

    return $datastore->cleanUp();
}

1;

__END__

=head1 NAME

AssetSync::Agent::Task::Deploy::Maintenance - Maintenance for Deploy task

=head1 DESCRIPTION

This module provides the Maintenance run function to cleanup Deploy environment.

=head1 FUNCTIONS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<logger>

the logger object to use (default: a new stderr logger)

=item I<config>

=item I<target>

=back

=head2 doMaintenance()

Cleanup the deploy datastore associated with the target.
