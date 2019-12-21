# == Class: influxdb::repos
#
# This is a container class holding default parameters for influxdb module.
#
class influxdb::repos (
  $apt_location          = $influxdb::params::apt_location,
  $apt_release           = $influxdb::params::apt_release,
  $apt_repos             = $influxdb::params::apt_repos,
  $apt_key               = $influxdb::params::apt_key,
  $influxdb_package_name = $influxdb::params::influxdb_package_name,
  $influxdb_service_name = $influxdb::params::influxdb_service_name
) inherits influxdb::params {
  case $::operatingsystem {
    /(?i:debian|devuan|ubuntu)/: {
      case $::lsbdistcodename {
        /(buster|n\/a)/   : {
          if !defined(Class['apt']) {
            include apt
          }

          apt::source { 'influxdb':
            ensure   => present,
            location => $apt_location,
            release  => 'jessie',
            repos    => 'stable',
            key      => $apt_key,
          }
        }
        default : {
          if !defined(Class['apt']) {
            include apt
          }

          apt::source { 'influxdb':
            ensure   => present,
            location => $apt_location,
            release  => $apt_release,
            repos    => $apt_repos,
            key      => $apt_key,
          }
        }
      }
    }
    /(?i:centos|fedora|redhat)/: {
      yumrepo { 'influxdb':
        ensure   => present,
        name     => 'InfluxDB',
        baseurl  => 'https://repos.influxdata.com/centos/$releasever/$basearch/stable',
        enabled  => true,
        gpgcheck => true,
        gpgkey   => 'https://repos.influxdata.com/influxdb.key',
      }
    }
    default                    : {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }
}
# EOF
