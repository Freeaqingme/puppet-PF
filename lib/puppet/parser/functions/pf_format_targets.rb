
module Puppet::Parser::Functions
  newfunction(:pf_format_targets, :type => :rvalue, :doc => <<-EOS
Format PF from or to arguments based on various inputs
    EOS
  ) do |args|
    direction, target_v4, target_v6, target_table = args

    raise(ArgumentError, "direction should be either from or to") unless ['from', 'to'].include?(direction)

    targets = []

    targets.concat(target_v4) unless target_v4.length == 0
    targets.concat(target_v6) unless target_v6.length == 0
    targets.push("<#{target_table}>") unless target_table.length == 0

    # return any when no targets are defined
    return " #{direction} any" unless targets.length > 0

    # see if besides 'all hosts' other hosts are defined
    targets_copy = targets
    targets_copy.delete("0.0.0.0/0")
    targets_copy.delete("::")
    return " #{direction} any" unless targets_copy.length > 0

    # remove curly braces with only 1 target (purely cosmetical)
    return " #{direction} #{targets[0]}" unless targets.length > 1

    # return comma-seperated list in curly braces
    return " #{direction} {" + targets.sort.join(', ') + "}"
  end
end
