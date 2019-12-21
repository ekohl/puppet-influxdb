# == Class: influxdb::privilege
#
define influxdb::privilege (
  String[1] $db_user,
  String[1] $db_name,
  Enum['absent', 'present'] $ensure       = present,
  Enum['ALL', 'READ', 'WRITE'] $privilege = 'ALL',
  Boolean $https_enable                   = $influxdb::https_enable,
  Boolean $http_auth_enabled              = $influxdb::http_auth_enabled,
  Optional[String[1]] $admin_username     = $influxdb::admin_username,
  Optional[String[1]] $admin_password     = $influxdb::admin_password
) {
  if $https_enable {
    $args_https = ' -ssl -unsafeSsl'
  } else {
    $args_https = ''
  }

  if $http_auth_enabled {
    $args_auth = " -username ${admin_username} -password '${admin_password}'"
  } else {
    $args_auth = ''
  }

  $cmd = "influx${args_https}${args_auth}"

  $matches = "grep ${db_name} | grep ${privilege}"
  if $ensure == 'absent' {
    exec { "revoke_${privilege}_on_${db_name}_to_${db_user}":
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command => "${cmd} -execute 'REVOKE ${privilege} ON \"${db_name}\" TO \"${db_user}\"'",
      onlyif  => "${cmd} -execute 'SHOW GRANTS FOR \"${db_user}\"' | ${matches}",
    }
  } elsif $ensure == 'present' {
    exec { "grant_${privilege}_on_${db_name}_to_${db_user}":
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command => "${cmd} -execute 'GRANT ${privilege} ON \"${db_name}\" TO \"${db_user}\"'",
      unless  => "${cmd} -execute 'SHOW GRANTS FOR \"${db_user}\"' | ${matches}",
    }
  }
}
# EOF
