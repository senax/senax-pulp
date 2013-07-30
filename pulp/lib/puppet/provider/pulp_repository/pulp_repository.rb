# https://github.com/glarizza/puppet-1/blob/feature/osx_dscl_providers/optimization/lib/puppet/provider/user/directoryservice.rb
# http://www.masterzen.fr/2011/11/02/puppet-extension-point-part-2/
require 'json'
require 'net/http'
require 'net/https'
require 'uri'

# resource = should
# property_hash = is

Puppet::Type.type(:pulp_repository).provide(:pulp_rpm_repo) do
  confine :osfamily => :redhat
  defaultfor :osfamily => :redhat

  mk_resource_methods

  def exists?
puts "*****************"
puts "exists?"
    @property_hash[:ensure] == :present
  end

  def create
puts "*****************"
puts "create"
    @property_flush[:create] = true
    self.class.resource_type.validproperties.each do |property|
      if val = resource.should(property)
        @property_hash[property] = val
      end
    end
    @property_hash[:ensure] = :present
  end

  def destroy
puts "*****************"
puts "destroy"
    @property_flush[:destroy] = true
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
  @rest_host='localhost'
  @rest_port=443
  @rest_user='admin'
  @rest_passwd='admin'
    repos = self.repolist # get array of all repos
    repos.collect do |repo|
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
  response = http.request(req)
  response.body
end
#private_class_method :restapi_get

def self.restapi_post(path,data)
  http = Net::HTTP.new(@rest_host,@rest_port)
  http.use_ssl = true
  http.verify_mode= OpenSSL::SSL::VERIFY_NONE # OpenSSL::SSL::VERIFY_PEER

  req = Net::HTTP::Post.new("/pulp/api/v2#{path}")
  req.basic_auth @rest_user,@rest_passwd
  req.body=data.to_json
  response = http.request(req)
  response.body
end
#private_class_method :restapi_post

def self.restapi_put(path,data)
  http = Net::HTTP.new(@rest_host,@rest_port)
  http.use_ssl = true
  http.verify_mode= OpenSSL::SSL::VERIFY_NONE # OpenSSL::SSL::VERIFY_PEER

  req = Net::HTTP::Put.new("/pulp/api/v2#{path}")
  req.basic_auth @rest_user,@rest_passwd
  req.body=data.to_json
  response = http.request(req)
  response.body
end
#private_class_method :restapi_put

def self.restapi_delete(path)
  http = Net::HTTP.new(@rest_host,@rest_port)
  http.use_ssl = true
  http.verify_mode= OpenSSL::SSL::VERIFY_NONE # OpenSSL::SSL::VERIFY_PEER

  req = Net::HTTP::Delete.new("/pulp/api/v2#{path}")
  req.basic_auth @rest_user,@rest_passwd
  response = http.request(req)
  response.body
end
#private_class_method :restapi_delete

def self.repolist
puts "*****************"
puts "self.repolist"

  raw_repos = restapi_get('/repositories/')
  repos = []

  JSON.parse(raw_repos).each do |repo|
    res = {}
    res[:ensure] = :present
    res[:name] = repo['id']
    res[:display_name] = repo['display_name']
    res[:description] = repo['description']
    res[:notes] = repo['notes']
    res[:rpms] = repo['content_unit_counts']['rpm']
    res[:package_groups] = repo['content_unit_counts']['package_group']
    importers = JSON.parse(restapi_get("/repositories/#{repo['id']}/importers/"))
    res[:pulp_importers]={}
    importers.each do |imp|
      res[:pulp_importers][imp["id"]]=imp["config"]
    end

# pulp-admin -u admin -p admin rpm repo sync schedules create --schedule '2012-12-15T00:00Z/P1D' --repo-id pulptest
# curl --user admin:admin --insecure https://localhost/pulp/api/v2/repositories/pulptest/importers/yum_importer/schedules/syncffdb75d10000f9/
#{"next_run": "2013-07-28T21:14:20Z", "_href": "/pulp/api/v2/repositories/pulptest/importers/yum_importer/schedules/sync/51e4581c2fffdb75d10000f9/", "schedule": "PT1H", "override_config": {}, "remaining_runs": null, "first_run": "2013-07-15T21:14:20Z", "enabled": true, "last_run": "2013-07-28T04:14:20Z", "failure_threshold": null, "_id": "51e4581c2fffdb75d10000f9", "consecutive_failures": 0}
#puts "-----------"
#puts "raw sync"
#p raw_sync_schedules

    distributors = JSON.parse(restapi_get("/repositories/#{repo['id']}/distributors/"))
    res[:pulp_distributors]={}
    distributors.each do |dist|
      res[:pulp_distributors][dist["id"]]=dist["config"]
    end
    repos << res
  end 
  repos
end

def initialize(value={})
  super(value)
  @property_flush={}
end

def display_name=(value)
  @property_flush[:display_name]=value
end

def description=(value)
  @property_flush[:description]=value
end

def notes=(value)
  @property_flush[:notes]=value
end

  def flush
puts "*****************"
puts "in flush"
puts "@property_hash"
p @property_hash
puts "@property_flush"
p @property_flush
#puts "resource"
#p resource
p @property_flush[:create]
p @property_flush[:destroy]
p @property_hash[:ensure]
p resource[:ensure]
p resource[:name]
p resource[:description]
p resource[:display_name]
if @property_flush[:create] # should not exist
    puts "flush -> create"
    data={}
    data[:id]=resource[:name]
    data[:display_name]=resource[:display_name] if resource[:display_name]
    data[:description]=resource[:description] if resource[:description]
    data[:notes]=resource[:notes] if resource[:notes]
    reply = self.class.restapi_post("/repositories/",data)
    p reply
elsif @property_flush[:destroy]
  puts "flush -> destroy"
  reply = self.class.restapi_delete("/repositories/#{resource[:name]}/")
  p reply
else
  puts "flush -> update"
  if @property_flush
# do things, depending on which properties have changed
    delta={}
    if @property_flush[:display_name]
      puts "update display name to #{resource[:display_name]}"
      delta[:display_name]=resource[:display_name]
    end
    if @property_flush[:description]
      puts "update description to #{resource[:description]}"
      delta[:description]=resource[:description]
    end
    if @property_flush[:notes]
      puts "update notes to #{resource[:notes]}"
      delta[:notes]=resource[:notes]
    end
    if delta
      data={}
      data[:delta]=delta
      reply = self.class.restapi_put("/repositories/#{resource[:name]}/",data)
      p reply
    end
  end
end
    @property_hash = resource.to_hash
  end

end
