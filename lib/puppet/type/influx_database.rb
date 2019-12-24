require 'puppet/parameter/boolean'

Puppet::Type.newtype(:influx_database) do
  @doc = "Manage an influx database"

  ensurable

  newparam(:name) do
    desc "The name of the database."
  end

  newparam(:https_enable, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc "Enable HTTPS when managing the database"
  end

  newparam(:http_auth_enabled, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc "Enable HTTP authentication when managing the database"
  end

  newparam(:admin_username) do
    desc "Admin username when HTTP authentication is enabled"
  end

  newparam(:admin_password) do
    desc "Admin password when HTTP authentication is enabled"
  end

  autorequire(:class) do
    'Influxdb'
  end
end
