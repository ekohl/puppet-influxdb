# == Class: influxdb
#
# Puppet module to install, deploy and configure influxdb.
#
class influxdb (
  Enum['present', 'latest', 'purged'] $package_ensure = 'present',
  Enum['running', 'stopped'] $service_ensure = 'running',
  Boolean $manage_repo     = true,
  $apt_location            = 'https://repos.influxdata.com/debian',
  $apt_release             = undef,
  $apt_repos               = 'stable',
  $apt_key                 = '05CE15085FC09D18E99EFB22684A14CF2582E0C5',
  String[1] $influxdb_package_name = 'influxdb',
  $influxdb_service_name   = $influxdb::params::influxdb_service_name,
  # daemon settings
  $hostname                = $::fqdn,
  $libdir                  = '/var/lib/influxdb',
  Boolean $admin_enable    = false,
  $admin_bind_address      = '0.0.0.0:8083',
  String[1] $admin_username = 'admin',
  Optional[String[1]] $admin_password = undef,
  $domain_name             = undef,
  Boolean $http_enable     = true,
  $http_bind_address       = '0.0.0.0:8086',
  BOolean $http_auth_enabled = false,
  $http_realm              = 'InfluxDB',
  Boolean $http_log_enabled = true,
  Boolean $https_enable    = true,
  $http_bind_socket        = '/var/run/influxdb.sock',
  $logging_format          = 'auto',
  $logging_level           = 'info',
  $max_series_per_database = 1000000,
  $max_values_per_tag      = 100000,
  Boolean $udp_enable      = false,
  $udp_bind_address        = '0.0.0.0:8089',

  Boolean $graphite_enable = false,
  $graphite_database       = 'graphite',
  $graphite_listen         = ':2003',
  $graphite_templates      = ['*.app env.service.resource.measurement', 'server'],

) inherits influxdb::params {
  if $manage_repo {
    class { 'influxdb::repos':
      apt_location          => $apt_location,
      apt_release           => $apt_release,
      apt_repos             => $apt_repos,
      apt_key               => $apt_key,
      influxdb_package_name => $influxdb_package_name,
      influxdb_service_name => $influxdb_service_name,
      before                => Package[$influxdb_package_name],
    }
  }

  package { $influxdb_package_name:
    ensure => $package_ensure,
  }

  service { $influxdb_service_name:
    ensure  => $service_ensure,
    enable  => $service_ensure == 'running',
    require => Package[$influxdb_package_name],
  }

  if $package_ensure == 'purged' {
    $file_ensure = 'absent'
  } else {
    $file_ensure = 'file'
  }

  file { '/etc/influxdb/influxdb.conf':
    ensure  => $file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('influxdb/influxdb.conf.erb'),
    require => Package[$influxdb_package_name],
    notify  => Service[$influxdb_service_name],
  }
}
# EOF
