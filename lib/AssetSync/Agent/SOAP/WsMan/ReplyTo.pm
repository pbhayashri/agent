package AssetSync::Agent::SOAP::WsMan::ReplyTo;

use strict;
use warnings;

use AssetSync::Agent::SOAP::WsMan::Node;

## no critic (ProhibitMultiplePackages)
package
    ReplyTo;

use parent
    'Node';

use constant    xmlns   => 'a';

use AssetSync::Agent::SOAP::WsMan::Address;

sub anonymous {
    my ($class) = @_;

    return $class->new(Address->anonymous);
}

1;
