define pf::rule (
    $action            = 'pass',
    $direction         = 'in',
    $in_interface      = '',
    $out_interface     = '', # unimplemented
    $source            = '',
    $source_v6         = '',
    $source_table      = '',
    $destination       = '',
    $destination_v6    = '',
    $destination_table = '',
    $protocol,
    $port,
    $sport             = '',
    $state             = 'keep',
    $order             = '',
    $log               = '', # unimplemented
    $enable            = '', # unimplemented
    $max_src_nodes     = '',
    $max_src_states    = '',
    $max_src_conn      = '',
    $max_src_conn_rate = '',
    $overload_table    = '',
) {

    include ::pf

    # The concat module may not support natural sorting,
    # so we make sure it's all at least 4 digits
    $true_order = $order ? {
      ''      => inline_template("<%= scope.lookupvar('pf::default_order').to_s.rjust(4, '0') %>"),
      default => inline_template("<%= @order.to_s.rjust(4, '0') %>")
    }

    $do_source = pf_format_targets('from', $source, $source_v6, $source_table)

    $do_destination = pf_format_targets('to', $destination, $destination_v6, $destination_table)

    if $action == 'block' {
        $do_log = ' log'
    }

    if $in_interface != '' {
        $do_interface = " on ${in_interface}"
    }

    if $protocol != '' {
        $do_protocol = " proto ${protocol}"
    }

    if $port != '' {
        $do_port = " port ${port}"
    }

    if $sport != '' {
        $do_sport = " port ${sport}"
    }

    # TODO: refactor this ... :|
    if $state != 'no'
        and $state != 'keep'
        and $state != 'modulate'
        and $state != 'synproxy'
    {
        fail("state can only be one of keep, modulate or synproxy")
    }

    $do_state = " ${state} state"

    # max_src_nodes, max_src_states, max_src_conn, max_src_conn_rate, overload_table
    $do_ratelimit = pf_format_ratelimit($max_src_nodes, $max_src_states, $max_src_conn, $max_src_conn_rate, $overload_table)

    # action [direction] [log] [quick] [on interface] [af] [proto protocol] \
    #    [from src_addr [port src_port]] [to dst_addr [port dst_port]] \
    #       [flags tcp_flags] [state]

    concat::fragment { "${module_name}-rule-${name}":
        target  => $pf::config_file,
        order   => $true_order,
        content => "${action} ${direction}${do_log} quick${do_interface}${do_protocol}${do_source}${do_sport}${do_destination}${do_port}${do_state}${do_ratelimit}\n",
        notify  => Exec['pf-reload'],
    }

}
