#!/usr/bin/perl

use strict;
use warnings;

use Config;
use Test::Deep;
use Test::Exception;
use Test::More;

use AssetSync::Agent::Version;
use AssetSync::Agent::Inventory;
use AssetSync::Agent::XML;
use AssetSync::Agent::XML::Query::Inventory;

plan tests => 6;

my $query;
throws_ok {
    $query = AssetSync::Agent::XML::Query::Inventory->new();
} qr/^no content/, 'no content';

my $inventory =  AssetSync::Agent::Inventory->new();
lives_ok {
    $query = AssetSync::Agent::XML::Query::Inventory->new(
        deviceid => 'foo',
        content  => $inventory->getContent()
    );
} 'everything OK';

isa_ok($query, 'AssetSync::Agent::XML::Query::Inventory');

my $AgentString = $AssetSync::Agent::Version::PROVIDER."-Inventory_v".$AssetSync::Agent::Version::VERSION;

my $xml = AssetSync::Agent::XML->new(string => $query->getContent());

isa_ok($xml, 'AssetSync::Agent::XML');

cmp_deeply(
    $xml->dump_as_hash(),
    {
        REQUEST => {
            DEVICEID => 'foo',
            QUERY    => 'INVENTORY',
            CONTENT  => {
                HARDWARE => {
                    VMSYSTEM => 'Physical'
                },
                VERSIONCLIENT => $AgentString,
            },
        }
    },
    'empty inventory, expected content'
);

$inventory->addEntry(
    section => 'SOFTWARES',
    entry   => {
        NAME => '<&>',
    }
);

$query = AssetSync::Agent::XML::Query::Inventory->new(
    deviceid => 'foo',
    content => $inventory->getContent()
);

cmp_deeply(
    $xml->string($query->getContent())->dump_as_hash(),
    {
        REQUEST => {
            DEVICEID => 'foo',
            QUERY => 'INVENTORY',
            CONTENT => {
                HARDWARE => {
                    VMSYSTEM => 'Physical'
                },
                VERSIONCLIENT => $AgentString,
                SOFTWARES => {
                    NAME => '<&>'
                }
            },
        }
    },
    'additional content with prohibited characters, expected content'
);
