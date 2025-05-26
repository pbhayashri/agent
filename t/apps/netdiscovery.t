#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use English qw(-no_match_vars);
use Test::More;
use UNIVERSAL::require;
use Config;

use AssetSync::Agent::Tools;
use AssetSync::Test::Utils;

AssetSync::Agent::Task::NetDiscovery->use();

plan tests => 9;

my ($out, $err, $rc);

($out, $err, $rc) = run_executable('assetsync-netdiscovery', '--help');
ok($rc == 0, '--help exit status');
like(
    $out,
    qr/^Usage:/,
    '--help stdout'
);
is($err, '', '--help stderr');

($out, $err, $rc) = run_executable('assetsync-netdiscovery', '--version');
ok($rc == 0, '--version exit status');
is($err, '', '--version stderr');
like(
    $out,
    qr/$AssetSync::Agent::Task::NetDiscovery::VERSION/,
    '--version stdout'
);

($out, $err, $rc) = run_executable('assetsync-netdiscovery', );
ok($rc == 2, 'no first address exit status');
like(
    $err,
    qr/no first or host address/,
    'no target stderr'
);
is($out, '', 'no target stdout');
