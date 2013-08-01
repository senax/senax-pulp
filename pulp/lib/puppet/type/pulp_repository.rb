#require 'pathname'
#require 'uri'

# http://pulp-dev-guide.readthedocs.org/en/latest/integration/rest-api/repo/cud.html
Puppet::Type.newtype(:pulp_repository) do
  desc 'pulp_repository is a custom type to manage Pulp repositories'
  ensurable

  newparam(:name, :namevar => true) do
    desc 'the name/repo-id of this repository'
  end

  newproperty(:display_name ) do
    desc 'the display_name of this repository'
  end

  newproperty(:description) do
  end

  newproperty(:notes) do
    desc "notes should be a hash"
    defaultto ({'_repo-type' => 'rpm-repo'})
    validate do |value|
      value.is_a? Hash
    end
  end

  newproperty(:package_groups_ro) do
    validate do |val|
      fail "package_groups is read-only"
    end
  end

  newproperty(:rpms_ro) do
    validate do |val|
      fail "rpms is read-only"
    end
  end
 
  newproperty(:pulp_importer) do
    validate do |value|
      value.is_a? Hash
    end
  end

  newproperty(:pulp_distributors) do
    validate do |value|
      value.is_a? Hash
    end
  end

end

# curl --user admin:admin --insecure https://pulp1.thuis.moona.net/pulp/api/v2/repositories/
# curl --user admin:admin --insecure https://pulp1.thuis.moona.net/pulp/api/v2/repositories/schedules/
