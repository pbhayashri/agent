package AssetSync::Test::Inventory;

use strict;
use warnings;
use parent qw(AssetSync::Agent::Inventory);

use AssetSync::Agent::Config;
use AssetSync::Agent::Logger;

sub new {
    my ($class, %params) = @_;

    my $logger = AssetSync::Agent::Logger->new(
        config => AssetSync::Agent::Config->new(
            options => {
                config => 'none',
                debug  => 2,
                logger => 'Fatal'
            }
        )
    );

    return $class->SUPER::new(logger => $logger);
}

1;
