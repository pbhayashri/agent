package AssetSync::Agent::SOAP::WsMan::DesiredStream;

use strict;
use warnings;

use AssetSync::Agent::SOAP::WsMan::Node;

## no critic (ProhibitMultiplePackages)
package
    DesiredStream;

use parent
    'Node';

use AssetSync::Agent::SOAP::WsMan::Attribute;

use constant    xmlns   => 'rsp';

sub new {
    my ($class, $cid) = @_;

    my $self = $class->SUPER::new(
        Attribute->new( CommandId => $cid ),
        "stdout stderr",
    );

    bless $self, $class;

    return $self;
}

1;
