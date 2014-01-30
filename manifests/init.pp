class pf(
	$interface,
    $trusted_networks,
) inherits pf::params {

	# paths
	file { "${module_name}-path":
		name => "${pf::params::pf_anchor_path}",
		ensure => directory,
	}

	# config checking and reloading firewall
	Exec {
		path => '/sbin',
        user => 'root',
	}

	exec { "${module_name}-check":
		command => "pfctl -nf ${pf::params::pf_conf}",
		refreshonly => true,
		notify => Exec["${module_name}-reload"],
        require => Service["${module_name}-service"],
	}

	exec { "${module_name}-reload":
		command => "pfctl -f ${pf::params::pf_conf}",
		refreshonly => true,
	}

	# service
	service { "${module_name}-service":
		ensure => running,
		enable => true,
		name => "pf",
	}

	service { "${module_name}-log-service":
		ensure => running,
		enable => true,
		name => "pflog",
		require => Service["${module_name}-service"],
	}

	# config file
	concat { "${module_name}-config":
		name => "${pf::params::pf_conf}",
		owner => 'root',
		group => 'wheel',
		mode => '0644',
		notify => Exec["${module_name}-check"],
	}

	concat::fragment { "${module_name}-config-options":
		target => "${pf::params::pf_conf}",
		content => template("${module_name}/pf.conf-options.erb"),
		notify => Exec["${module_name}-check"],
		order => 1,
	}

	concat::fragment { "${module_name}-config-rules":
		target => "${pf::params::pf_conf}",
		content => template("${module_name}/pf.conf-rules.erb"),
		notify => Exec["${module_name}-check"],
		order => 2,
	}
}
