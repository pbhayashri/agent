package
    DebDistro;

use strict;
use warnings;

use parent 'LinuxDistro';

BEGIN {
    $INC{"DebDistro.pm"} = __FILE__;
}

use InstallerVersion;

my $DEBREVISION = "1";
my $DEBVERSION = InstallerVersion::VERSION();
# Add package a revision on official releases
$DEBVERSION .= "-$DEBREVISION" unless $DEBVERSION =~ /-.+$/;

my %DebPackages = (
    "assetsync-agent"                => qr/^inventory$/i,
    "assetsync-agent-task-network"   => qr/^netdiscovery|netinventory|network$/i,
    "assetsync-agent-task-collect"   => qr/^collect$/i,
    "assetsync-agent-task-esx"       => qr/^esx$/i,
    "assetsync-agent-task-deploy"    => qr/^deploy$/i,
    #"assetsync-agent-task-wakeonlan" => qr/^wakeonlan|wol$/i,
);

my %DebInstallTypes = (
    all     => [ qw(
        assetsync-agent
        assetsync-agent-task-network
        assetsync-agent-task-collect
        assetsync-agent-task-esx
        assetsync-agent-task-deploy
    ) ],
    typical => [ qw(assetsync-agent) ],
    network => [ qw(
        assetsync-agent
        assetsync-agent-task-network
    ) ],
);

sub init {
    my ($self) = @_;

    # Store installation status for each supported package
    foreach my $deb (keys(%DebPackages)) {
        my $version = qx(dpkg-query --show --showformat='\${Version}' $deb 2>/dev/null);
        next if $?;
        $version =~ s/^\d+://;
        $self->{_packages}->{$deb} = $version;
    }

    # Try to figure out installation type from installed packages
    if ($self->{_packages} && !$self->{_type}) {
        my $installed = join(",", sort keys(%{$self->{_packages}}));
        $self->{_type} = "custom";
        foreach my $type (keys(%DebInstallTypes)) {
            my $install_type = join(",", sort @{$DebInstallTypes{$type}});
            if ($installed eq $install_type) {
                $self->{_type} = $type;
                last;
            }
        }
        $self->verbose("Guessed installation type: $self->{_type}");
    }

    # Call parent init to figure out some defaults
    $self->SUPER::init();
}

sub _extract_deb {
    my ($self, $deb) = @_;
    my $pkg = $deb."_${DEBVERSION}_all.deb";
    $self->verbose("Extracting $pkg ...");
    $self->{_archive}->extract("pkg/deb/$pkg")
        or die "Failed to extract $pkg: $!\n";
    my $pwd = $ENV{PWD} || qx/pwd/;
    chomp($pwd);
    return $pwd =~ /\s/ ? "'$pwd/$pkg'" : "$pwd/$pkg";
}

sub install {
    my ($self) = @_;

    $self->verbose("Trying to install assetsync-agent v$DEBVERSION on $self->{_release} release ($self->{_name}:$self->{_version})...");

    my $type = $self->{_type} // "typical";
    my %pkgs = qw( assetsync-agent 1 );
    if ($DebInstallTypes{$type}) {
        map { $pkgs{$_} = 1 } @{$DebInstallTypes{$type}};
    } else {
        foreach my $task (split(/,/, $type)) {
            my ($pkg) = grep { $DebPackages{$_} && $task =~ $DebPackages{$_} } keys(%DebPackages);
            $pkgs{$pkg} = 1 if $pkg;
        }
    }

    # Check installed packages
    if ($self->{_packages}) {
        # Auto-select still installed packages
        map { $pkgs{$_} = 1 } keys(%{$self->{_packages}});

        foreach my $pkg (keys(%pkgs)) {
            if ($self->{_packages}->{$pkg}) {
                if ($self->{_packages}->{$pkg} eq $DEBVERSION) {
                    $self->verbose("$pkg still installed and up-to-date");
                    delete $pkgs{$pkg};
                } else {
                    $self->verbose("$pkg will be upgraded");
                }
            }
        }
    }

    # Don't install skipped packages
    map { delete $pkgs{$_} } keys(%{$self->{_skip}});

    my @pkgs = sort keys(%pkgs);
    if (@pkgs) {
        # The archive may have been prepared for a specific distro with expected deps
        # So we just need to install them too
        map { $pkgs{$_} = $_ } $self->getDeps("deb");

        foreach my $pkg (@pkgs) {
            $pkgs{$pkg} = $self->_extract_deb($pkg);
        }

        if (!$self->{_skip}->{dmidecode} && qx{uname -m 2>/dev/null} =~ /^(i.86|x86_64)$/ && ! $self->which("dmidecode")) {
            $self->verbose("Trying to also install dmidecode ...");
            $pkgs{dmidecode} = "dmidecode";
        }

        # Be sure to have pci.ids & usb.ids on recent distro as its dependencies were removed
        # from packaging to support older distros
        if (!-e "/usr/share/misc/pci.ids" && qx{dpkg-query --show --showformat='\${Package}' pciutils 2>/dev/null}) {
            $self->verbose("Trying to also install pci.ids ...");
            $pkgs{"pci.ids"} = "pci.ids";
        }
        if (!-e "/usr/share/misc/usb.ids" && qx{dpkg-query --show --showformat='\${Package}' usbutils 2>/dev/null}) {
            $self->verbose("Trying to also install usb.ids ...");
            $pkgs{"usb.ids"} = "usb.ids";
        }

        my @debs = sort values(%pkgs);
        my @options = ( "-y" );
        push @options, "--allow-downgrades" if $self->downgradeAllowed();
        my $command = "apt @options install @debs 2>/dev/null";
        my $err = $self->run($command);
        die "Failed to install assetsync-agent\n" if $err;
        $self->{_installed} = \@debs;
    } else {
        $self->{_installed} = 1;
    }

    # Call parent installer to configure and install service or crontab
    $self->SUPER::install();
}

sub uninstall {
    my ($self) = @_;

    my @debs = sort keys(%{$self->{_packages}});

    return $self->info("assetsync-agent is not installed")
        unless @debs;

    $self->uninstall_service();

    $self->info(
        @debs == 1 ? "Uninstalling assetsync-agent package..." :
            "Uninstalling ".scalar(@debs)." assetsync-agent related packages..."
    );
    my $err = $self->run("apt -y purge --autoremove @debs 2>/dev/null");
    die "Failed to uninstall assetsync-agent\n" if $err;

    map { delete $self->{_packages}->{$_} } @debs;

    # Also remove cron file if found
    unlink "/etc/cron.hourly/assetsync-agent" if -e "/etc/cron.hourly/assetsync-agent";
}

sub clean {
    my ($self) = @_;

    $self->SUPER::clean();

    unlink "/etc/default/assetsync-agent" if -e "/etc/default/assetsync-agent";
}

sub install_cron {
    my ($self) = @_;

    $self->info("assetsync-agent will be run every hour via cron");
    $self->verbose("Disabling assetsync-agent service...");
    my $ret = $self->run("systemctl disable assetsync-agent" . ($self->verbose ? "" : " 2>/dev/null"));
    return $self->info("Failed to disable assetsync-agent service") if $ret;
    $self->verbose("Stopping assetsync-agent service if running...");
    $ret = $self->run("systemctl stop assetsync-agent" . ($self->verbose ? "" : " 2>/dev/null"));
    return $self->info("Failed to stop assetsync-agent service") if $ret;

    $self->verbose("Installing assetsync-agent hourly cron file...");
    my $cron = $self->open_os_file('/etc/cron.hourly/assetsync-agent', '>')
        or die "Can't create hourly crontab for assetsync-agent: $!\n";
    print $cron q{#!/bin/bash

NAME=assetsync-agent
LOG=/var/log/$NAME-cron.log

exec >>$LOG 2>&1

[ -f /etc/default/$NAME ] || exit 0
source /etc/default/$NAME
export PATH

: ${OPTIONS:=--wait 120 --lazy}

echo "[$(date '+%c')] Running $NAME $OPTIONS"
/usr/bin/$NAME $OPTIONS
echo "[$(date '+%c')] End of cron job ($PATH)"
};
    $self->close_os_file();
    $self->chmod_os_file(0755, '/etc/cron.hourly/assetsync-agent');
    unless ($self->os_file_exists('/etc/default/assetsync-agent')) {
        $self->verbose("Installing assetsync-agent system default config...");
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
