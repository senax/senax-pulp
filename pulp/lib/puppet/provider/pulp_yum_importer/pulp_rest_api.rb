require File.join(File.dirname(__FILE__),'..','pulp')

Puppet::Type.type(:pulp_yum_importer).provide(:pulp_rest_api, :parent => Puppet::Provider::Pulp) do
  confine :osfamily => :redhat
  defaultfor :osfamily => :redhat

  mk_resource_methods

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
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
    importers = self.importerlist # get array of all repos
    importers.collect do |importer|
      self.new(importer) # create new object for each repo
    end
  end

  def self.prefetch(resources)
#puts "*****************"
    # Prefetching is necessary to use @property_hash inside any setter methods.
    # self.prefetch uses self.instances to gather an array of user instances
    # on the system, and then populates the @property_hash instance variable
    # with attribute data for the specific instance in question (i.e. it
    # gathers the 'is' values of the resource into the @property_hash instance
    # variable so you don't have to read from the system every time you need
    # to gather the 'is' values for a resource. The downside here is that
    # populating this instance variable for every resource on the system
    # takes time and front-loads your Puppet run.
#puts "prefetch"
    found_importers = instances
#p found_importers
    resources.keys.each do |name|
      if provider = found_importers.find{|found_importer| found_importer.name == name }
        resources[name].provider = provider
      end
    end
  end

def self.importerlist
puts "importerlist"
  raw_repos = restapi_get('/repositories/')
  importerlist = []

config_options_string=[ 'feed_url', 'ssl_ca_cert', 'ssl_client_cert', 'ssl_client_key', 'proxy_pass', 'proxy_user', 'proxy_url', ] 
config_options_bool=[ 'ssl_verify', 'verify_size', 'verify_checksum', 'newest', 'remove_old', 'purge_orphaned', 'resolve_dependencies', ]
config_options_int=[ 'proxy_port', 'max_speed', 'num_threads', 'num_old_packages', 'checksum_type', 'num_retries', 'retry_delay', ]
config_options_array=[ 'skip', ]
config_options=[config_options_string,config_options_bool,config_options_int,config_options_array].flatten

  JSON.parse(raw_repos).each do |repo|
    res = {}
    res[:ensure] = :present
    res[:name] = repo['id']
    importers = JSON.parse(restapi_get("/repositories/#{repo['id']}/importers/"))
    importers.each do |imp|
# from : /usr/lib/pulp/plugins/importers/yum_importer/importer.py
config_options.each do |prop|
      res[prop.to_sym]=imp["config"][prop] if imp["config"][prop]
#res[prop.to_sym]=res[prop.to_sym].to_i if config_options_int.include?(prop)
#res[prop.to_sym]=res[prop.to_sym].to_s if config_options_string.include?(prop)
#res[prop.to_sym]=res[prop.to_sym].to_a if config_options_array.include?(prop)
#res[prop.to_sym]=res[prop.to_sym].eql?('true') if config_options_bool.include?(prop)
end
    end
    importerlist << res
  end 
  importerlist
end

def initialize(value={})
puts "---init---"
  super(value)
  @property_flush={}
end

def feed_url=(value)
  @property_flush[:feed_url]=value
end

  def flush
puts "flush"

#if @property_flush[:create] # should not exist
    data={}
    data[:importer_type_id]='yum_importer'
    data[:importer_config]={}
config_options_string=[ 'feed_url', 'ssl_ca_cert', 'ssl_client_cert', 'ssl_client_key', 'proxy_pass', 'proxy_user', 'proxy_url', ] 
config_options_bool=[ 'ssl_verify', 'verify_size', 'verify_checksum', 'newest', 'remove_old', 'purge_orphaned', 'resolve_dependencies', ]
config_options_int=[ 'proxy_port', 'max_speed', 'num_threads', 'num_old_packages', 'checksum_type', 'num_retries', 'retry_delay', ]
config_options_array=[ 'skip', ]
config_options=[config_options_string,config_options_bool,config_options_int,config_options_array].flatten
config_options.each do |prop|
if resource[prop.to_sym]
resource[prop.to_sym]=resource[prop.to_sym].to_i if config_options_int.include?(prop)
resource[prop.to_sym]=resource[prop.to_sym].to_s if config_options_string.include?(prop)
resource[prop.to_sym]=resource[prop.to_sym].to_a if config_options_array.include?(prop)
resource[prop.to_sym]=resource[prop.to_sym].eql?('true') if config_options_bool.include?(prop)
  data[:importer_config][prop.to_sym]=resource[prop.to_sym]
end
end
puts data.to_json
    reply = self.class.restapi_post("/repositories/#{resource[:name]}/importers/",data)
puts reply
#elsif @property_flush[:destroy]
#puts "destroy"
#    data={}
#    data[:importer_type_id]='yum_importer'
#    data[:importer_config]={}
#  reply = self.class.restapi_post("/repositories/#{resource[:name]}/importers/",data)
#else
#  if @property_flush
#      delta={}
#    if @property_flush[:feed_url]
#puts "flush, feedurl"
#      delta[:display_name]=resource[:display_name]
#    end
#    if @property_flush[:description]
#      delta[:description]=resource[:description]
#    end
#    if @property_flush[:notes]
#      delta[:notes]=resource[:notes]
#    end
#    if delta
#      data={}
#      data[:delta]=delta
#      reply = self.class.restapi_put("/repositories/#{resource[:name]}/",data)
#    end
#  end
# handle importer and distributors here?
#end
    @property_hash = resource.to_hash
  end

end
