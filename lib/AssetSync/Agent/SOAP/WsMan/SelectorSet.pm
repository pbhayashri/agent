package AssetSync::Agent::SOAP::WsMan::SelectorSet;

use strict;
use warnings;

use AssetSync::Agent::SOAP::WsMan::Node;

## no critic (ProhibitMultiplePackages)
package
    SelectorSet;

use parent
    'Node';

use AssetSync::Agent::SOAP::WsMan::Selector;

use constant    xmlns   => 'w';

sub support {
    return {
        Selector    => "w:Selector",
    };
}

1;
