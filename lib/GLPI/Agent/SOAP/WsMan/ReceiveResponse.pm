package AssetSync::Agent::SOAP::WsMan::ReceiveResponse;

use strict;
use warnings;

use AssetSync::Agent::SOAP::WsMan::Node;

## no critic (ProhibitMultiplePackages)
package
    ReceiveResponse;

use parent
    'Node';

use constant    xmlns   => 'rsp';

sub support {
    return {
        Stream          => "rsp:Stream",
        CommandState    => "rsp:CommandState",
    };
}

1;
