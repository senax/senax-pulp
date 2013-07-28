# https://github.com/glarizza/puppet-1/blob/feature/osx_dscl_providers/optimization/lib/puppet/provider/user/directoryservice.rb
# http://www.masterzen.fr/2011/11/02/puppet-extension-point-part-2/
require 'json'
require 'net/http'
require 'net/https'
require 'uri'

Puppet::Type.type(:pulprepo).provide(:pulp_rpm_repo) do
  confine :osfamily => :redhat
  defaultfor :osfamily => :redhat
#  commands :curl =>  'curl'
#  @apiuri = 'https://localhost/pulp/api/v2/repositories/'

  mk_resource_methods
#'curl --user admin:admin --insecure https://localhost/pulp/api/v2/repositories/'

  def exists?
puts "*****************"
puts "exists?"
#puts "@property_hash"
#p @property_hash
#puts "resource"
#p resource
    @property_hash[:ensure] == :present
  end

  def create
puts "*****************"
puts "create"
    @property_hash[:ensure] = :present
    self.class.resource_type.validproperties.each do |property|
      if val = resource.should(property)
        @property_hash[property] = val
      end
    end
  end

  def destroy
puts "*****************"
puts "destroy"
    @property_hash[:ensure] = :absent
  end

  def self.instances
puts "*****************"
    # This method assembles an array of provider instances containing
    # information about every instance of the user type on the system (i.e.
    # every user and its attributes). The `puppet resource` command relies
    # on self.instances to gather an array of user instances in order to
    # display its output.
puts "self.instances"
#p resources
    repos = self.repolist # get array of all repos
    repos.collect do |repo|
#      p repo
      self.new(repo) # create new object for each repo
    end
  end

  def self.prefetch(resources)
puts "*****************"
    # Prefetching is necessary to use @property_hash inside any setter methods.
    # self.prefetch uses self.instances to gather an array of user instances
    # on the system, and then populates the @property_hash instance variable
    # with attribute data for the specific instance in question (i.e. it
    # gathers the 'is' values of the resource into the @property_hash instance
    # variable so you don't have to read from the system every time you need
    # to gather the 'is' values for a resource. The downside here is that
    # populating this instance variable for every resource on the system
    # takes time and front-loads your Puppet run.
puts "prefetch"
    found_repos = instances
    resources.keys.each do |name|
      if provider = found_repos.find{|found_repo| found_repo.name == name }
        resources[name].provider = provider
      end
    end
  end

def self.restapi_get(path)
  http = Net::HTTP.new(@rest_host,@rest_port)
  http.use_ssl = true
  http.verify_mode= OpenSSL::SSL::VERIFY_NONE # OpenSSL::SSL::VERIFY_PEER

  req = Net::HTTP::Get.new("/pulp/api/v2#{path}")
  req.basic_auth @rest_user,@rest_passwd
  http.request(req).body
end
private_class_method :restapi_get

  def self.repolist
puts "*****************"
puts "self.repolist"
  @rest_host='localhost'
  @rest_port=443
  @rest_user='admin'
  @rest_passwd='admin'

raw_repos = restapi_get('/repositories/')
    repos = []

    JSON.parse(raw_repos).each { |repo|
      res = {}
      res[:repoid] = repo['id'].to_s
      res[:name] = repo['id']
#      repo[:feed] = "http://voedsel/"
      res[:display_name] = repo['display_name']
#"content_unit_counts": {"package_group": 3, "rpm": 42}
      res[:rpms] = repo['content_unit_counts']['rpm']
      res[:package_groups] = repo['content_unit_counts']['package_group']
      res[:ensure] = :present
      raw_importers =  restapi_get("/repositories/#{repo['id']}/importers/")
       importers = JSON.parse(raw_importers)
res[:pulp_importers]={}
importers.each do |imp|
  res[:pulp_importers][imp["id"]]=imp["config"]

# pulp-admin -u admin -p admin rpm repo sync schedules create --schedule '2012-12-15T00:00Z/P1D' --repo-id pulptest
# curl --user admin:admin --insecure https://localhost/pulp/api/v2/repositories/pulptest/importers/yum_importer/schedules/syncffdb75d10000f9/
#{"next_run": "2013-07-28T21:14:20Z", "_href": "/pulp/api/v2/repositories/pulptest/importers/yum_importer/schedules/sync/51e4581c2fffdb75d10000f9/", "schedule": "PT1H", "override_config": {}, "remaining_runs": null, "first_run": "2013-07-15T21:14:20Z", "enabled": true, "last_run": "2013-07-28T04:14:20Z", "failure_threshold": null, "_id": "51e4581c2fffdb75d10000f9", "consecutive_failures": 0}
#puts "-----------"
#puts "raw sync"
#p raw_sync_schedules

end
      #raw_distributors =  curl('--silent','--user','admin:admin','--insecure',"https://localhost/pulp/api/v2/repositories/#{repo['id']}/distributors/")
      raw_distributors =  restapi_get("/repositories/#{repo['id']}/distributors/")
       distributors = JSON.parse(raw_distributors)
res[:pulp_distributors]={}
distributors.each do |dist|
#puts "*******************"
#puts "dist"
  res[:pulp_distributors][dist["id"]]=dist["config"]

#p dist
end
#       res [:feed] = importers[0]['config']['feed_url']
       #p importers[0]
#       repos << new(:name => repo['id'] ,:ensure => :present, :feed => feeduri)
#     }
      repos << res
    }
    repos
  end

def initialize(value={})
puts "*****************"
puts "initialize"
  super(value)
  @property_flush={}
end

def display_name=(value)
  @property_flush[:display_name]=value
end

  def flush
puts "*****************"
puts "in flush"
puts "@property_hash"
p @property_hash
puts "resource"
#p resource
    if @property_flush
# do things, depending on which properties have changed
      if @property_flush[:display_name]
        puts "update display name to #{resource[:display_name]}"
      end
    end
    @property_hash = resource.to_hash
#    @repos.destroy if @repos
  end

#  def feed
#p "@property_hash=", @property_hash
#    @property_hash[:feed]
#  end

#  def feed=
#  code to update the feed for a given resource
#  don't forget to update @property_hash[:feed]=resource[:feed]
#  end

#  def repoid
#    resource[:name]
#  end

#  def collect
#  end
end
