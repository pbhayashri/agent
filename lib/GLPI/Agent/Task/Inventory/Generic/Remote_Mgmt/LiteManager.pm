package AssetSync::Agent::Task::Inventory::Generic::Remote_Mgmt::LiteManager;

use strict;
use warnings;

use parent 'AssetSync::Agent::Task::Inventory::Module';

use AssetSync::Agent::Tools;

sub isEnabled {
    return 0 unless OSNAME eq 'MSWin32';

    AssetSync::Agent::Tools::Win32->use();

    my $key;
    first {
        $key = AssetSync::Agent::Tools::Win32::getRegistryKey(
            path        => $_,
            # Important for remote inventory optimization
            required    => [ 'ID (read only)' ],
            maxdepth    => 3,
        ) && $key && keys(%{$key})
    } qw(
        HKEY_LOCAL_MACHINE/SYSTEM/LiteManager
        HKEY_LOCAL_MACHINE/SOFTWARE/LiteManager
    );
    return $key && keys(%{$key});
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $liteManagerID = _getID( logger => $logger );

    if ($liteManagerID) {
        $logger->debug('Found LiteManagerID : ' . $liteManagerID) if ($logger);

        $inventory->addEntry(
            section => 'REMOTE_MGMT',
            entry   => {
                ID   => $liteManagerID,
                TYPE => 'litemanager'
            }
        );
    } else {
        $logger->debug('LiteManagerID not found') if ($logger);
    }
}

sub _getID {
    my (%params) = @_;

    my $id;
    first {
        $id = _findID(
            path => $_,
            %params
        )
    } qw(
        HKEY_LOCAL_MACHINE/SYSTEM/LiteManager
        HKEY_LOCAL_MACHINE/SOFTWARE/LiteManager
    );

    return $id;
}

sub _findID {
    my (%params) = @_;

    AssetSync::Agent::Tools::Win32->use();

    my $key = AssetSync::Agent::Tools::Win32::getRegistryKey(
        %params,
        # Important for remote inventory optimization
        required    => [ 'ID (read only)' ],
        maxdepth    => 3,
    );

    return unless $key && keys(%{$key});

    my $parameters;

    foreach my $sub (grep { m|/$| } keys(%{$key})) {
        next unless $key->{$sub}->{"Server/"};
        next unless $key->{$sub}->{"Server/"}->{"Parameters/"};
        $parameters = $key->{$sub}->{"Server/"}->{"Parameters/"};
        last if $parameters->{"/ID (read only)"};
    }

    return unless $parameters;

    return $parameters->{"/ID (read only)"};
}

1;
