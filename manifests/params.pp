# == Class: influxdb::params
#
class influxdb::params {
  case $::operatingsystem {
    /(?i:debian|devuan|ubuntu)/: {
      $influxdb_service_name = 'influxdb'
    }
    /(?i:centos|fedora|redhat)/: {
      $influxdb_service_name = $::operatingsystemmajrelease ? {
        '6' => 'influxdb',
        '7' => 'influxd'
      }
    }
    default: {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }
}
# EOF
