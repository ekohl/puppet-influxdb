# == Class: influxdb::database
#
define influxdb::database (
  Enum['absent', 'present'] $ensure   = present,
  String[1] $db_name                  = $title,
  Boolean $https_enable               = $influxdb::https_enable,
  Boolean $http_auth_enabled          = $influxdb::http_auth_enabled,
  Optional[String[1]] $admin_username = $influxdb::admin_username,
  Optional[String[1]] $admin_password = $influxdb::admin_password
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

  if $ensure == 'absent' {
    exec { "drop_database_${db_name}":
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command => "${cmd} -execute 'DROP DATABASE ${db_name}'",
      onlyif  => "${cmd} -execute 'SHOW DATABASES' | tail -n+3 | grep -x ${db_name}",
    }
  } elsif $ensure == 'present' {
    exec { "create_database_${db_name}":
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
      command => "${cmd} -execute 'CREATE DATABASE ${db_name}'",
      unless  => "${cmd} -execute 'SHOW DATABASES' | tail -n+3 | grep -x ${db_name}",
    }
  }
}
# EOF
