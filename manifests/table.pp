define pf::table {

  include ::pf

  concat { "pf_table_${name}":
    path => "/etc/pf.d/${name}.table",
    notify  => Exec['pf-reload']
  }

  concat::fragment { "pf_table_entry__header_${name}":
    target  => "pf_table_${name}",
    content => "# File managed by puppet\n\n",
    order   => 0,
    notify  => Exec['pf-reload']
  }

  concat::fragment { "${module_name}-table-${name}":
    target  => $pf::config_file,
    order   => 150,
    notify  => Exec['pf-reload'],
    content => "table <${name}> persist file \"/etc/pf.d/${name}.table\"\n",
  }

}
