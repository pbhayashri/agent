#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use Test::Deep;
use Test::Exception;
use Test::More;
use Test::NoWarnings;

use AssetSync::Test::Inventory;
use AssetSync::Agent::Task::Inventory::Virtualization::Parallels;
use AssetSync::Agent::Tools::Virtualization;

my %tests = (
    sample1 => [
        {
            VMTYPE    => 'parallels',
            NAME      => 'Ubuntu Linux',
            SUBSYSTEM => 'Parallels',
            STATUS    => STATUS_OFF,
            UUID      => 'bc993872-c70f-40bf-b2e2-94d9f080eb55'
        }
    ]
);

plan tests => (2 * scalar keys %tests) + 1;

my $inventory = AssetSync::Test::Inventory->new();

foreach my $test (keys %tests) {
    my $file = "resources/virtualization/prlctl/$test";
    my @machines = AssetSync::Agent::Task::Inventory::Virtualization::Parallels::_parsePrlctlA(file => $file);
    cmp_deeply(\@machines, $tests{$test}, "$test: parsing");
    lives_ok {
        $inventory->addEntry(section => 'VIRTUALMACHINES', entry => $_)
            foreach @machines;
    } "$test: registering";
}
