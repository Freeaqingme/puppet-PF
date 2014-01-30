define pf::anchor (
	$interface,
	$service,
	$port,
	$protocol = 'tcp',
	$whitelist = [],
	$blacklist = [],
	$order = 50
) {
	# init main module
	if ! defined(Class["${module_name}"]) {
		class { "${module_name}": }
	}

	# config checking and reloading firewall
	Exec {
		path => "/sbin"
	}

	$anchor_file = "${pf::params::pf_anchor_path}/anchor-${service}"

	# wrap port argument in array
	# when not already an array
	if is_array($port) {
		$ports = $port
	} else {
		$ports = [ $port ]
	}

	# wrap protocol argument in array
	# when not already an array
	if is_array($protocol) {
		$protocols = $protocol
	} else {
		$protocols = [ $protocol ]
	}

	# wrap interface argument in array
	# when not already an array
	if is_array($interface) {
		$interfaces = $interface
	} else {
		$interfaces = [ $interface ]
	}

	# prepare anchor file
	file { "${module_name}-anchor-${service}":
		name => "${anchor_file}",
		content => template("${module_name}/anchor.erb"),
		notify => Exec["${module_name}-anchor-${service}-check"],
		mode => '0444',
	}

	# limit outer values of order
	# less than 10 and 99999 are reserved
	if $order >= 99999 {
		$concat_order = 99998
	} elsif $order <= 10 {
		$concat_order = 10
	} else {
		$concat_order = $order
	}

	# add loading anchor to main pf file
	concat::fragment { "${module_name}-${service}":
		target => "${pf::params::pf_conf}",
		content => template("${module_name}/anchor-load.erb"),
		require => File["${module_name}-anchor-${service}"],
		notify => Exec["${module_name}-check"],
		order => $concat_order,
	}

	# check syntax of anchor file
	# if syntax checks out, notify reloading anchor
	exec { "${module_name}-anchor-${service}-check":
		command => "pfctl -n -a ${service} -f ${anchor_file}",
		refreshonly => true,
		notify => Exec["${module_name}-anchor-${service}-reload"],
        require => Service["${module_name}-service"],
	}

	# reload anchor config
	exec { "${module_name}-anchor-${service}-reload":
		command => "pfctl -a ${service} -f ${anchor_file}",
		refreshonly => true,
	}
}
