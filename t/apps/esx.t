#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use English qw(-no_match_vars);
use Test::More;

use AssetSync::Agent::Task::ESX;
use AssetSync::Test::Utils;

plan tests => 13;

my ($out, $err, $rc);

($out, $err, $rc) = run_executable('assetsync-esx', '--help');
ok($rc == 0, '--help exit status');
is($err, '', '--help stderr');
like(
    $out,
    qr/^Usage:/,
    '--help stdout'
);

($out, $err, $rc) = run_executable(
    'assetsync-esx',
    '--host unknowndevice --user a --password a --directory /tmp'
);
like($err, qr/500\s\S/, 'Bad hostname');

($out, $err, $rc) = run_executable('assetsync-esx', '--version');
ok($rc == 0, '--version exit status');
is($err, '', '--version stderr');
like(
    $out,
    qr{assetsync-esx $AssetSync::Agent::Task::ESX::VERSION},
    '--version stdout'
);

SKIP: {
    skip "No gunzip command on win32", 6
            if $OSNAME eq "MSWin32";

    ($out, $err, $rc) = run_executable('assetsync-esx', '--dumpfile resources/esx/esx-4.1.0-1-hostfullinfo.dump.gz');
    ok($rc == 0, '--dumpfile exit status');
    is($err, '', '--dumpfile stderr');
    like(
        $out,
        qr{<DEVICEID>esx-test\.teclib\.local-\d+-\d+-\d+-\d+-\d+-\d+</DEVICEID>},
        '--dumpfile stdout'
    );

    ($out, $err, $rc) = run_executable('assetsync-esx', '--json --dumpfile resources/esx/esx-4.1.0-1-hostfullinfo.dump.gz');
    ok($rc == 0, '--json --dumpfile exit status');
    is($err, '', '--json --dumpfile stderr');
    like(
        $out,
        qr{"deviceid": "esx-test\.teclib\.local-\d+-\d+-\d+-\d+-\d+-\d+",},
        '--json --dumpfile stdout'
    );
}
