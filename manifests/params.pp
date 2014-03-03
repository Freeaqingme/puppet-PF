class pf::params {

    $config_file = '/etc/pf.conf'
    $config_path = '/etc/pf.d/'

    $config_file_mode = $::operatingsystem ? {
      default => '0644',
    }

    $config_file_owner = $::operatingsystem ? {
      default => 'root',
    }

    $config_file_group = $::operatingsystem ? {
      /^(Open|Free)BSD$/ => 'wheel',
      default            => 'root',
    }

    # general settings
    $loopback_interface = 'lo0'
}
