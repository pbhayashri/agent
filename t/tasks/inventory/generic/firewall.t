#!/usr/bin/perl

use strict;
use warnings;

use AssetSync::Agent::Tools::Constants;
use AssetSync::Agent::Task::Inventory::Generic::Firewall::Ufw;
use AssetSync::Agent::Task::Inventory::Generic::Firewall::Systemd;

use Test::More;

my $expectedUbuntu = {
    'ubuntu_ufw_status_ON.txt'  => STATUS_ON,
    'ubuntu_ufw_status_OFF.txt' => STATUS_OFF
};

my $expectedFedora = {
    'fedora_systemctl_status_firewalld.service_ON.txt'  => STATUS_ON,
    'fedora_systemctl_status_firewalld.service_ON_disabled.txt' => STATUS_ON
};

plan tests => scalar (keys %$expectedUbuntu)
        + scalar (keys %$expectedFedora);

for my $testfile (keys %$expectedUbuntu) {
    my $statusGot = AssetSync::Agent::Task::Inventory::Generic::Firewall::Ufw::_getFirewallStatus(
        file => 'resources/linux/firewall/' . $testfile
    );
    ok ($statusGot eq $expectedUbuntu->{$testfile});
}

for my $testfile (keys %$expectedFedora) {
    my $statusGot = AssetSync::Agent::Task::Inventory::Generic::Firewall::Systemd::_getFirewallStatus(
        file => 'resources/linux/firewall/' . $testfile
    );
    ok ($statusGot eq $expectedFedora->{$testfile}, $testfile . ' : ' . $statusGot . ' eq ' . $expectedFedora->{$testfile} . ' ?');
}
