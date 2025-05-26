package
    SnapInstall;

use strict;
use warnings;

use parent 'LinuxDistro';

BEGIN {
    $INC{"SnapInstall.pm"} = __FILE__;
}

use InstallerVersion;

sub init {
    my ($self) = @_;

    die "Can't install assetsync-agent via snap without snap installed\n"
        unless $self->which("snap");

    $self->{_bin} = "/snap/bin/assetsync-agent";

    # Store installation status of the current snap
    my ($version) = qx{snap info assetsync-agent 2>/dev/null} =~ /^installed:\s+(\S+)\s/m;
    return if $?;
    $self->{_snap}->{version} = $version;
}

sub install {
    my ($self) = @_;

    $self->verbose("Trying to install assetsync-agent v".InstallerVersion::VERSION()." via snap on $self->{_release} release ($self->{_name}:$self->{_version})...");

    # Check installed packages
    if ($self->{_snap}) {
        if (InstallerVersion::VERSION() =~ /^$self->{_snap}->{version}/ ) {
            $self->verbose("assetsync-agent still installed and up-to-date");
        } else {
            $self->verbose("assetsync-agent will be upgraded");
            delete $self->{_snap};
        }
    }

    if (!$self->{_snap}) {
        my ($snap) = grep { m|^pkg/snap/.*\.snap$| } $self->{_archive}->files()
            or die "No snap included in archive\n";
        $snap =~ s|^pkg/snap/||;
        $self->verbose("Extracting $snap ...");
        die "Failed to extract $snap\n" unless $self->{_archive}->extract("pkg/snap/$snap");
        my $err = $self->run("snap install --classic --dangerous $snap");
        die "Failed to install assetsync-agent snap package\n" if $err;
        $self->{_installed} = [ $snap ];
    } else {
        $self->{_installed} = 1;
    }

    # Call parent installer to configure and install service or crontab
    $self->SUPER::install();
}

sub configure {
    my ($self) = @_;

    # Call parent configure using snap folder
    $self->SUPER::configure("/var/snap/assetsync-agent/current");
}

sub uninstall {
    my ($self, $purge) = @_;

    return $self->info("assetsync-agent is not installed via snap")
        unless $self->{_snap};

    $self->info("Uninstalling assetsync-agent snap...");
    my $command = "snap remove assetsync-agent";
    $command .= " --purge" if $purge;
    my $err = $self->run($command);
    die "Failed to uninstall assetsync-agent snap\n" if $err;

    # Remove cron file if found
    unlink "/etc/cron.hourly/assetsync-agent" if -e "/etc/cron.hourly/assetsync-agent";

    delete $self->{_snap};
}

sub clean {
    my ($self) = @_;
    die "Can't clean assetsync-agent related files if it is currently installed\n" if $self->{_snap};
    $self->info("Cleaning...");
    # clean uninstall is mostly done using --purge option in uninstall
    unlink "/etc/default/assetsync-agent" if -e "/etc/default/assetsync-agent";
}

sub install_service {
    my ($self) = @_;

    $self->info("Enabling assetsync-agent service...");

    my $ret = $self->run("snap start --enable assetsync-agent" . ($self->verbose ? "" : " 2>/dev/null"));
    return $self->info("Failed to enable assetsync-agent service") if $ret;

    if ($self->{_runnow}) {
        # Still handle run now here to avoid calling systemctl in parent
        delete $self->{_runnow};
        $ret = $self->run($self->{_bin}." --set-forcerun" . ($self->verbose ? "" : " 2>/dev/null"));
        return $self->info("Failed to ask assetsync-agent service to run now") if $ret;
        $ret = $self->run("snap restart assetsync-agent" . ($self->verbose ? "" : " 2>/dev/null"));
        $self->info("Failed to restart assetsync-agent service on run now") if $ret;
    }
}

sub install_cron {
    my ($self) = @_;

    $self->info("assetsync-agent will be run every hour via cron");
    $self->verbose("Disabling assetsync-agent service...");
    my $ret = $self->run("snap stop --disable assetsync-agent" . ($self->verbose ? "" : " 2>/dev/null"));
    return $self->info("Failed to disable assetsync-agent service") if $ret;

    $self->verbose("Installin assetsync-agent hourly cron file...");
    my $cron = $self->open_os_file('/etc/cron.hourly/assetsync-agent', '>')
        or die "Can't create hourly crontab for assetsync-agent: $!\n";
    print $cron q{#!/bin/bash

NAME=assetsync-agent-cron
LOG=/var/log/$NAME.log

exec >>$LOG 2>&1

[ -f /etc/default/$NAME ] || exit 0
source /etc/default/$NAME
export PATH

: ${OPTIONS:=--wait 120 --lazy}

echo "[$(date '+%c')] Running $NAME $OPTIONS"
/snap/bin/$NAME $OPTIONS
echo "[$(date '+%c')] End of cron job ($PATH)"
};
    $self->close_os_file();
    unless ($self->os_file_exists('/etc/default/assetsync-agent')) {
        $self->verbose("Installin assetsync-agent system default config...");
        my $default = $self->open_os_file('/etc/default/assetsync-agent', '>')
            or die "Can't create system default config for assetsync-agent: $!\n";
        print $default q{
# By default, ask agent to wait a random time
OPTIONS="--wait 120"

# By default, runs are lazy, so the agent won't contact the server before it's time to
OPTIONS="$OPTIONS --lazy"
};
        $self->close_os_file();
    }
}

1;
