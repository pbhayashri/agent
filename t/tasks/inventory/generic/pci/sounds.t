#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use Test::Deep;
use Test::Exception;
use Test::More;
use Test::NoWarnings;

use AssetSync::Test::Inventory;
use AssetSync::Agent::Task::Inventory::Generic::PCI::Sounds;

my %tests = (
    'dell-xt2' => [
        {
            NAME => 'Audio device',
            DESCRIPTION => 'rev 03',
            MANUFACTURER => 'Intel Corporation 82801I (ICH9 Family) HD Audio Controller'
        }
    ],
    'linux-2' => [
        {
            DESCRIPTION  => 'rev 01',
            MANUFACTURER => 'Intel Corporation NM10/ICH7 Family High Definition Audio Controller',
            NAME         => 'Audio device'
        }
    ]
);

plan tests => (2 * scalar keys %tests) + 1;

my $inventory = AssetSync::Test::Inventory->new();

foreach my $test (keys %tests) {
    my $file = "resources/generic/lspci/$test";
    my @sounds = AssetSync::Agent::Task::Inventory::Generic::PCI::Sounds::_getSounds(file => $file);
    cmp_deeply(\@sounds, $tests{$test}, $test);
    lives_ok {
        $inventory->addEntry(section => 'SOUNDS', entry => $_)
            foreach @sounds;
    } "$test: registering";
}
