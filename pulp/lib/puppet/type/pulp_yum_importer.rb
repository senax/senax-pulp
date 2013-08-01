#require 'pathname'
#require 'uri'

# http://pulp-dev-guide.readthedocs.org/en/latest/integration/rest-api/repo/cud.html
Puppet::Type.newtype(:pulp_yum_importer) do
  desc 'pulp_yum_import is a custom type to manage the pulp yum_importers'
  ensurable

  newparam(:name, :namevar => true) do
    desc 'the name of the pulp_repository this importer is attached to'
  end
# 'feed_url', 'ssl_verify', 'ssl_ca_cert', 'ssl_client_cert', 'ssl_client_key',
#                        'proxy_url', 'proxy_port', 'proxy_pass', 'proxy_user',
#                        'max_speed', 'verify_size', 'verify_checksum', 'num_threads',
#                        'newest', 'remove_old', 'num_old_packages', 'purge_orphaned', 'skip', 'checksum_type',
#                        'num_retries', 'retry_delay', 'resolve_dependencies']
# feed_url: Repository URL
  newproperty(:feed_url) do
    desc "Repository URL"
    validate do |value|
      value.is_a? String
    end
  end
# ssl_verify: True/False to control if yum/curl should perform SSL verification of the host
  newproperty(:ssl_verify) do
    desc "ssl_verify URL"
    newvalue(:true)
    newvalue(:false)
  end
# ssl_ca_cert: String with SSL CA certificate used for ssl verification
  newproperty(:ssl_ca_cert) do
    desc "ssl_ca_cert"
    validate do |value|
      value.is_a? String
    end
  end
# ssl_client_cert: String with SSL Client certificate, used for protected repository access
  newproperty(:ssl_client_cert) do
    desc "ssl_client_cert"
    validate do |value|
      value.is_a? String
    end
  end
# ssl_client_key: String with SSL Client key, used for protected repository access
  newproperty(:ssl_client_key) do
    desc "ssl_client_key"
    validate do |value|
      value.is_a? String
    end
  end
# proxy_url: Proxy URL
  newproperty(:proxy_url) do
    desc "proxy_url"
    validate do |value|
      value.is_a? String
    end
  end
# proxy_port: Port Port
  newproperty(:proxy_port) do
    desc "proxy_port"
    validate do |value|
      value.is_a? Integer
    end
  end
# proxy_user: Username for Proxy
  newproperty(:proxy_user) do
    desc "proxy_user"
    validate do |value|
      value.is_a? String
    end
  end
# proxy_pass: Password for Proxy
  newproperty(:proxy_pass) do
    desc "proxy_pass"
    validate do |value|
      value.is_a? String
    end
  end
# max_speed: Limit the Max speed in KB/sec per thread during package downloads
  newproperty(:max_speed) do
    desc "max_speed KB/s"
    validate do |value|
#      value.is_a? String
    end
  end
# verify_checksum: if True will verify the checksum for each existing package repo metadata
  newproperty(:verify_checksum) do
    desc "verify_checksum"
    newvalue(:true)
    newvalue(:false)
  end
# verify_size: if True will verify the size for each existing package against repo metadata
  newproperty(:verify_size) do
    desc "verify_size"
    newvalue(:true)
    newvalue(:false)
  end
# num_threads: Controls number of threads to use for package download (technically number of processes spawned)
  newproperty(:num_threads) do
    desc "num_threads"
    validate do |value|
      value.is_a? Integer
    end
  end
# newest: Boolean option, if True only download the latest packages
  newproperty(:newest) do
    desc "download only newest"
#    validate do |value|
#      value.is_a? String
#    end
#    newvalue(0)
#    newvalue(1)
#    newvalue('true')
#    newvalue('false')
  end
# remove_old: Boolean option, if True remove old packages
  newproperty(:remove_old) do
    desc "remove_old"
    newvalue(:true)
    newvalue(:false)
  end
# num_old_packages: Defaults to 0, controls how many old packages to keep if remove_old is True
  newproperty(:num_old_packages) do
    desc "how many old packages to keep if remove_old is true"
    validate do |value|
      value.is_a? String
    end
  end
# purge_orphaned: Defaults to True, when True will delete packages no longer available from the source repository
  newproperty(:purge_orphaned) do
    desc "purge_orphaned"
    newvalue(:true)
    newvalue(:false)
  end
# skip: List of what content types to skip during sync, options:
#                     ["rpm", "drpm", "errata", "distribution", "packagegroup"]
  newproperty(:skip, :array_matching => :all) do
    desc "List of what content types to skip during sync; options: rpm,drpm,errata,distribution,packagegroup"
    validate do |value|
      value.is_a? Array
    end
  end
# checksum_type: checksum type to use for repodata; defaults to source checksum type or sha256
  newproperty(:checksum_type) do
    desc "checksum_type, sha256,sha"
    newvalue("sha256")
    newvalue("sha")
  end
# num_retries: Number of times to retry before declaring an error
  newproperty(:num_retries) do
    desc "number of times to retry before declaring an error"
    validate do |value|
      value.is_a? Integer
    end
  end
# retry_delay: Minimal number of seconds to wait before each retry
  newproperty(:retry_delay) do
    desc "Minimal number of seconds to wait before each retry"
    validate do |value|
      value.is_a? Integer
    end
  end
  newproperty(:resolve_dependencies) do
    desc "resolve_dependencies"
    newvalue(:true)
    newvalue(:false)
  end

# example: {"newest": true, "feed_url": "http://repos.fedorapeople.org/repos/pulp/pulp/v2/stable/6Server/x86_64/"}
#     newvalues(:yes, :no)


end

# curl --user admin:admin --insecure https://pulp1.thuis.moona.net/pulp/api/v2/repositories/
# curl --user admin:admin --insecure https://pulp1.thuis.moona.net/pulp/api/v2/repositories/schedules/
