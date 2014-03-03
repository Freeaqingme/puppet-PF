class pf (
    $header_template    = "${module_name}/pf.conf-header.erb",
    $block_policy       = 'drop',
    $scrub_traffic      = true,
    $block_to_broadcast = true,
    $block_urpf_failed  = true,
    $skip_loopback      = true,
    $scrub_traffic      = true,
    $enable_logging     = true,
    $timeouts           = {},
    $limits             = {},
) inherits pf::params {

    $default_order = 5000

    file { $pf::config_path:
        ensure => directory,
        owner  => $pf::config_file_owner,
        group  => $pf::config_file_group,
        mode   => '0755',
    }

    concat { 'pf.conf':
        ensure => present,
        name   => $pf::config_file,
        owner  => $pf::config_file_owner,
        group  => $pf::config_file_group,
        mode   => $pf::config_file_mode,
        notify  => Exec['pf-reload'],
    }

    concat::fragment { 'pf.conf-header':
        ensure  => present,
        target  => $pf::config_file,
        content => template($header_template),
    }

    # enable pf
    service { 'pf':
        ensure => running,
        enable => true,
    }

    # if wanted, enable pflog
    service { 'pflog':
        ensure => $enable_logging,
    }

    # reload firewall
    exec { 'pf-reload':
        command     => "pfctl -f ${pf::config_file}",
        user        => 'root',
        path        => ['/sbin'],
        refreshonly => true,
        require     => Service['pf'],
    }
}
