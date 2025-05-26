#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::NoWarnings;

use AssetSync::Agent::Task::Inventory::MacOS::OS;

my %installdate = (
    'macos-10.15' => "2020-11-30 13:06:34",
);

plan tests => (scalar keys %installdate) + 1;

foreach my $test (keys %installdate) {
    my $file = "resources/generic/stat/$test";
    my $installdate = AssetSync::Agent::Task::Inventory::MacOS::OS::_getInstallDate(file => $file);
    is($installdate, $installdate{$test}, "$test installdate");
}
