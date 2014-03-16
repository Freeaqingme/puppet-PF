define pf::table::entry (
  $table,
  $target  = '',
  $comment = '',
) {

  if $target != '' {
    $real_target = $target
  } else {
    $real_target = $name
  }

  if ! is_array($real_target) {
    $real_target_a = [ $real_target ]
  } else {
    $real_target_a = $real_target
  }

  if $comment != '' {
    $real_comment = "\t# ${comment}"
  } elsif $name != $real_target {
    $real_comment = "\t# ${name}"
  } else {
    $real_comment = ""
  }

  concat::fragment { "pf_table_entry_${name}":
    target  => "pf_table_${table}",
    content => inline_template('<%=@real_target_a.map!{|target| "#{target}#{@real_comment}" }.sort.join("\n").concat("\n") %>'),
    order   => 10
  }

}
