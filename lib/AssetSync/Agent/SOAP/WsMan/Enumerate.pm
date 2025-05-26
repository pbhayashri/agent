package AssetSync::Agent::SOAP::WsMan::Enumerate;

use strict;
use warnings;

use AssetSync::Agent::SOAP::WsMan::Node;

## no critic (ProhibitMultiplePackages)
package
    Enumerate;

use parent
    'Node';

use AssetSync::Agent::SOAP::WsMan::OptimizeEnumeration;
use AssetSync::Agent::SOAP::WsMan::MaxElements;

use constant    xmlns   => 'n';

sub new {
    my ($class, @params) = @_;

    my $self = $class->SUPER::new(@params);

    bless $self, $class;

    $self->push(
        OptimizeEnumeration->new(),
        MaxElements->new(32000),
    )
        unless @params;

    return $self;
}

1;
