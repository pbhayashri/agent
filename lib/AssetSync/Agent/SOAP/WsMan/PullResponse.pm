package AssetSync::Agent::SOAP::WsMan::PullResponse;

use strict;
use warnings;

use AssetSync::Agent::SOAP::WsMan::EnumerateResponse;

## no critic (ProhibitMultiplePackages)
package
    PullResponse;

use parent
    'EnumerateResponse';

sub support {
    return {
        EnumerationContext  => "n:EnumerationContext",
        Items               => "n:Items",
        EndOfSequence       => "n:EndOfSequence",
    };
}

1;
