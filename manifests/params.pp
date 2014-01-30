class pf::params {	
	case $::osfamily {
		'FreeBSD': {
			$pf_conf = "/etc/pf.conf"
			$pf_anchor_path = "/etc/pf.d/"
		}
		default: {
			fail("No support for ${::osfamily}")
		}
	}
}