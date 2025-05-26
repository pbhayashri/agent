#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use English qw(-no_match_vars);
use Test::More;

use AssetSync::Agent::Task::WakeOnLan;
use AssetSync::Test::Utils;

plan tests => 6;

my ($out, $err, $rc);

($out, $err, $rc) = run_executable('assetsync-wakeonlan', '--help');
ok($rc == 0, '--help exit status');
like(
    $out,
    qr/^Usage:/,
    '--help stdout'
);
is($err, '', '--help stderr');

($out, $err, $rc) = run_executable('assetsync-wakeonlan', '--version');
ok($rc == 0, '--version exit status');
is($err, '', '--version stderr');
like(
    $out,
    qr/$AssetSync::Agent::Task::WakeOnLan::VERSION/,
    '--version stdout'
);
