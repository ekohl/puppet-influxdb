Puppet::Type.type(:influx_database).provide(:cli) do
  desc "Manage influx_database via the CLI"

  confine :exists => '/usr/bin/influx'

  mk_resource_methods

  def self.execute_influx(command)
    cmd = ['/usr/bin/influx', '-execute', command, '-format', 'json']
    output = Puppet::Util::Execution.execute(cmd, failonfail: true)
    Puppet::Util::Json.load(output)
  end

  def self.instances
    result = execute_influx('SHOW DATABASES')
    result['results'][0]['values'].map { |value| new(name: value[0]) }
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def initialize(resource={})
    super(resource)
    @property_flush = {}
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def flush
    if @property_flush[:ensure] == :absent
      execute_influx("DROP DATABASE #{property_hash[:name]}")
    elsif @property_flush[:ensure] == :present
      execute_influx("CREATE DATABASE #{property_hash[:name]}")
    end
  end
end
