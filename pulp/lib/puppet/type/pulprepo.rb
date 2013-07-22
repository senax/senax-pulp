require 'pathname'
require 'uri'

Puppet::Type.newtype(:pulprepo) do
  desc 'pulprepo is a custom type to manage Pulp (rpm) repositories'
  ensurable

  newparam(:name, :namevar => true) do
    desc 'the name of a repository'
  end

  newproperty(:repoid ) do
    desc 'the repoid of a repository'
  end

  newproperty(:feed) do
  end

  newproperty(:display_name) do
  end

  newproperty(:package_groups) do
    validate do |val|
      fail "package_groups is read-onlu"
    end
  end

  newproperty(:rpms) do
    validate do |val|
      fail "rpms is read-onlu"
    end
  end

#  newparam(:apiuri) do
#    defaultto 'https://localhost/pulp/api/v2'
#    validate do |value|
#      unless Pathname.new(value).absolute? || URI.parse(value).is_a?(URI::HTTP)
#        fail("invalid apiurl #{value}")
#      end
#    end
#  end

#  newparam(:apiuser) do
#    defaultto 'admin'
#  end

#  newparam(:apipasswd) do
#    defaultto 'admin'
#  end

end

# curl --user admin:admin --insecure https://pulp1.thuis.moona.net/pulp/api/v2/repositories/
# curl --user admin:admin --insecure https://pulp1.thuis.moona.net/pulp/api/v2/repositories/schedules/
