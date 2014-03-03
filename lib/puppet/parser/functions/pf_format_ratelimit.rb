
module Puppet::Parser::Functions
  newfunction(:pf_format_ratelimit, :type => :rvalue, :doc => <<-EOS
Format rate limiting based on arguments
    EOS
  ) do |args|
    max_src_nodes, max_src_states, max_src_conn, max_src_conn_rate, overload_table = args

    raise(ArgumentError, "max_src_nodes should be numeric") unless (max_src_nodes.scan(/^[0-9]+$/) or max_src_nodes.length == 0)
    raise(ArgumentError, "max_src_states should be numeric") unless (max_src_states.scan(/^[0-9]+$/) or max_src_states.length == 0)
    raise(ArgumentError, "max_src_conn should be numeric") unless (max_src_conn.scan(/^[0-9]+$/) or max_src_conn.length == 0)
    raise(ArgumentError, "max_src_conn_rate should be in the format connections/seconds") unless (max_src_conn_rate.scan(/^[0-9]+\/[0-9]+$/) or max_src_conn_rate.length == 0)

    rules = []

    # IP bound
    rules.push("max-src-nodes #{max_src_nodes}") unless max_src_nodes.length == 0
    rules.push("max-src-states #{max_src_states}") unless max_src_states.length == 0

    # TCP bound
    rules.push("max-src-conn #{max_src_conn}") unless max_src_conn.length == 0
    rules.push("max-src-conn-rate #{max_src_conn_rate}") unless max_src_conn_rate.length == 0
    rules.push("overload <#{overload_table}> flush global") unless overload_table.length == 0

    # always use source-track on rule basis
    rules.unshift("source-track rule") unless rules.length == 0

    return '' unless rules.length > 0
    return " (" + rules.join(', ') + ")"
  end
end
