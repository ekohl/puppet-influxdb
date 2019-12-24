# == Class: influxdb
#
# Puppet module to install, deploy and configure influxdb.
#
class influxdb (
  Variant[Boolean, Enum['latest']] $package = true,
  Variant[Boolean, Enum['running']] $service = true,
  Boolean $enable          = true,
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
  case $package {
    true    : { $ensure_package = 'present' }
    false   : { $ensure_package = 'purged' }
    latest  : { $ensure_package = 'latest' }
    default : { fail('package must be true, false or lastest') }
  }

  case $service {
    true    : { $ensure_service = 'running' }
    false   : { $ensure_service = 'stopped' }
    running : { $ensure_service = 'running' }
    default : { fail('service must be true, false or running') }
  }

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
    ensure => $ensure_package,
  }

  service { $influxdb_service_name:
    ensure  => $ensure_service,
    enable  => $enable,
    require => Package[$influxdb_package_name],
  }

  file { '/etc/influxdb/influxdb.conf':
    ensure  => $ensure_package,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('influxdb/influxdb.conf.erb'),
    require => Package[$influxdb_package_name],
    notify  => Service[$influxdb_service_name],
  }
}
# EOF
