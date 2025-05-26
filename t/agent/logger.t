#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use English qw(-no_match_vars);
use IO::Capture::Stderr;
use File::stat;
use File::Temp qw(tempdir);
use Fcntl qw(:seek);
use Test::More;
use Test::NoWarnings;

use AssetSync::Agent::Config;
use AssetSync::Agent::Logger;

plan tests => 29;

my $logger = AssetSync::Agent::Logger->new();

isa_ok(
    $logger,
    'AssetSync::Agent::Logger',
    'logger class'
);

is(
    @{$logger->{backends}},
    1,
    'one default backend'
);

isa_ok(
    $logger->{backends}->[0],
    'AssetSync::Agent::Logger::Stderr',
    'default backend class'
);

if ($OSNAME eq 'MSWin32') {

    $logger = AssetSync::Agent::Logger->new(
        config => AssetSync::Agent::Config->new(
            options => {
                config  => 'none',
                logger  => 'stderr,Test'
            }
        )
    );
    is(
        @{$logger->{backends}},
        2,
        'three backends'
    );

    subtest 'backends classes' => sub {
        plan tests => 2;
        isa_ok(
            $logger->{backends}->[0],
            'AssetSync::Agent::Logger::Stderr',
            'first backend class'
        );

        isa_ok(
            $logger->{backends}->[1],
            'AssetSync::Agent::Logger::Test',
            'third backend class'
        );
    };
} else {
    $logger = AssetSync::Agent::Logger->new(
        config => AssetSync::Agent::Config->new(
            options => {
                config  => 'none',
                logger  => 'Stderr,Syslog,Test'
            }
        )
    );

    is(
        @{$logger->{backends}},
        3,
        'three backends'
    );

    subtest 'backends classes' => sub {
        plan tests => 3;
        isa_ok(
            $logger->{backends}->[0],
            'AssetSync::Agent::Logger::Stderr',
            'first backend class'
        );

        isa_ok(
            $logger->{backends}->[1],
            'AssetSync::Agent::Logger::Syslog',
            'second backend class'
        );

        isa_ok(
            $logger->{backends}->[2],
            'AssetSync::Agent::Logger::Test',
            'third backend class'
        );
    };
}

# stderr backend tests

$logger = AssetSync::Agent::Logger->new(
    config => AssetSync::Agent::Config->new(
        options => {
            config  => 'none',
            logger  => 'stderr'
        }
    )
);

ok(
    !getStderrOutput(sub { $logger->debug2('message'); }),
    'debug2 message absence'
);

ok(
    !getStderrOutput(sub { $logger->debug('message'); }),
    'debug message absence'
);

# Test just updating debug level
$logger = AssetSync::Agent::Logger->new(
    debug => 1
);

ok(
    !getStderrOutput(sub { $logger->debug2('message'); }),
    'debug2 message absence'
);

ok(
    getStderrOutput(sub { $logger->debug('message'); }),
    'debug message presence'
);

is(
    getStderrOutput(sub { $logger->debug('message'); }),
    "[debug] message",
    'debug message formatting'
);

is(
    getStderrOutput(sub { $logger->info('message'); }),
    "[info] message",
    'info message formatting'
);

is(
    getStderrOutput(sub { $logger->warning('message'); }),
    "[warning] message",
    'warning message formatting'
);

is(
    getStderrOutput(sub { $logger->error('message'); }),
    "[error] message",
    'error message formatting'
);

$logger = AssetSync::Agent::Logger->new(
    config => AssetSync::Agent::Config->new(
        options => {
            config  => 'none',
            debug   => 2,
            logger  => 'stderr'
        }
    )
);

ok(
    getStderrOutput(sub { $logger->debug2('message'); }),
    'debug2 message presence'
);

ok(
    getStderrOutput(sub { $logger->debug('message'); }),
    'debug message presence'
);

$logger = AssetSync::Agent::Logger->new(
    config => AssetSync::Agent::Config->new(
        options => {
            config  => 'none',
            debug   => 1,
            color   => 1,
            logger  => 'stderr'
        }
    )
);

is(
    getStderrOutput(sub { $logger->debug('message'); }),
    "\033[1;1m[debug]\033[0m message",
    'debug message color formatting'
);

is(
    getStderrOutput(sub { $logger->info('message'); }),
    "\033[1;34m[info]\033[0m message",
    'info message color formatting'
);

is(
    getStderrOutput(sub { $logger->warning('message'); }),
    "\033[1;35m[warning] message\033[0m",
    'warning message color formatting'
);

is(
    getStderrOutput(sub { $logger->error('message'); }),
    "\033[1;31m[error] message\033[0m",
    'error message color formatting'
);

# Test just updating color config
$logger = AssetSync::Agent::Logger->new(
    color => 0
);

is(
    getStderrOutput(sub { $logger->error('message'); }),
    "[error] message",
    'error message after color formatting removed'
);

# file backend tests
my $tmpdir = tempdir(CLEANUP => $ENV{TEST_DEBUG} ? 0 : 1);
my $logfile;

$logfile = "$tmpdir/test1";
$logger = AssetSync::Agent::Logger->new(
    config => AssetSync::Agent::Config->new(
        options => {
            config  => 'none',
            logger  => 'file',
            logfile => $logfile
        }
    )
);

$logger->debug('message');

ok(
    !-f $logfile,
    'debug message absence'
);

$logfile = "$tmpdir/test2";
$logger = AssetSync::Agent::Logger->new(
    config => AssetSync::Agent::Config->new(
        options => {
            config  => 'none',
            debug   => 1,
            logger  => 'file',
            logfile => $logfile
        }
    )
);
$logger->debug('message');

ok(
    -f $logfile,
    'debug message presence'
);

like(
    getFileOutput($logfile, sub { $logger->debug('message'); }),
    qr/^\[... ... .. ..:..:.. ....\]\[debug\] message/,
    'debug message formatting'
);

like(
    getFileOutput($logfile, sub { $logger->info('message'); }),
    qr/^\[... ... .. ..:..:.. ....\]\[info\] message/,
    'info message formatting'
);

like(
    getFileOutput($logfile, sub { $logger->warning('message'); }),
    qr/^\[... ... .. ..:..:.. ....\]\[warning\] message/,
    'warning message formatting'
);

like(
    getFileOutput($logfile, sub { $logger->error('message'); }),
    qr/^\[... ... .. ..:..:.. ....\]\[error\] message/,
    'error message formatting'
);

$logfile = "$tmpdir/test3";
$logger = AssetSync::Agent::Logger->new(
    config => AssetSync::Agent::Config->new(
        options => {
            config  => 'none',
            logger  => 'file',
            logfile => $logfile
        }
    )
);
fillLogFile($logger);
ok(
    getFileSize($logfile) > 1024 * 1024,
    'no size limitation'
);

$logfile = "$tmpdir/test4";
$logger = AssetSync::Agent::Logger->new(
    config => AssetSync::Agent::Config->new(
        options => {
            config  => 'none',
            logger  => 'file',
            logfile => $logfile,
            'logfile-maxsize' => 1
        }
    )
);
fillLogFile($logger);
ok(
    getFileSize($logfile) < 1024 * 1024,
    'size limitation'
);

sub getStderrOutput {
    my ($callback) = @_;

    my $capture = IO::Capture::Stderr->new();

    $capture->start();
    $callback->();
    $capture->stop();

    my $line = $capture->read();
    chomp $line if $line;

    return $line;
}

sub getFileOutput {
    my ($file, $callback) = @_;

    my $stat = stat $file;

    $callback->();

    open (my $fh, '<', $file) or die "can't open $file: $ERRNO";
    seek $fh, $stat->size(), SEEK_SET;
    my $line = <$fh>;
    close $fh;

    chomp $line;
    return $line;
}

sub fillLogFile {
    my ($logger) = @_;
    foreach my $i (0 .. 1023) {
        $logger->info(chr(65 + $i % 26) x 1024);
    }
}

sub getFileSize {
    my ($file) = @_;
    my $stat = stat $file;
    return $stat->size();
}
