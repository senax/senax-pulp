require 'net/http'
require 'net/https'
require 'json'
require 'uri'

# resource = should
# property_hash = is

class Puppet::Provider::Pulp < Puppet::Provider
  private
  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    @property_flush[:create] = true
    self.class.resource_type.validproperties.each do |property|
      if val = resource.should(property)
        @property_hash[property] = val
      end
    end
    @property_hash[:ensure] = :present
  end

  def destroy
    @property_flush[:destroy] = true
    @property_hash[:ensure] = :absent
  end

  def self.instances
    # This method assembles an array of provider instances containing
    # information about every instance of the user type on the system (i.e.
    # every user and its attributes). The `puppet resource` command relies
    # on self.instances to gather an array of user instances in order to
    # display its output.
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
    # Prefetching is necessary to use @property_hash inside any setter methods.
    # self.prefetch uses self.instances to gather an array of user instances
    # on the system, and then populates the @property_hash instance variable
    # with attribute data for the specific instance in question (i.e. it
    # gathers the 'is' values of the resource into the @property_hash instance
    # variable so you don't have to read from the system every time you need
    # to gather the 'is' values for a resource. The downside here is that
    # populating this instance variable for every resource on the system
    # takes time and front-loads your Puppet run.
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

def self.restapi_delete(path)
  http = Net::HTTP.new(@rest_host,@rest_port)
  http.use_ssl = true
  http.verify_mode= OpenSSL::SSL::VERIFY_NONE # OpenSSL::SSL::VERIFY_PEER

  req = Net::HTTP::Delete.new("/pulp/api/v2#{path}")
  req.basic_auth @rest_user,@rest_passwd
  response = http.request(req)
  response.body
end

def self.repolist
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
    if @property_flush[:create] 
      data={}
      data[:id]=resource[:name]
      data[:display_name]=resource[:display_name] if resource[:display_name]
      data[:description]=resource[:description] if resource[:description]
      data[:notes]=resource[:notes] if resource[:notes]
      reply = self.class.restapi_post("/repositories/",data)
    elsif @property_flush[:destroy]
      reply = self.class.restapi_delete("/repositories/#{resource[:name]}/")
    else
      if @property_flush
        delta={}
      if @property_flush[:display_name]
        delta[:display_name]=resource[:display_name]
      end
      if @property_flush[:description]
        delta[:description]=resource[:description]
      end
      if @property_flush[:notes]
        delta[:notes]=resource[:notes]
      end
      if delta
        data={}
        data[:delta]=delta
        reply = self.class.restapi_put("/repositories/#{resource[:name]}/",data)
      end
    end
    @property_hash = resource.to_hash
  end
end
end
