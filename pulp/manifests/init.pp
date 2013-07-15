# == Class: pulp
#
# Full description of class pulp here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { pulp:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2013 Your name here, unless otherwise noted.
#
class pulp {


yumrepo { 'pulp':
  descr      => 'pulp',
  gpgcheck   => '0',
  enabled => '1',
  baseurl => 'http://repos.fedorapeople.org/repos/pulp/pulp/v2/stable/6Server/x86_64/',
} ->

yumrepo { 'epel':
  descr          => 'Extra Packages for Enterprise Linux 6 - $basearch',
  enabled        => '1',
  failovermethod => 'priority',
  gpgcheck       => '1',
  gpgkey         => 'https://fedoraproject.org/static/0608B895.txt',
  mirrorlist     => 'https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=$basearch',
} ->

package{'httpd':
  ensure => installed,
} ->

package{'mongodb':
  ensure => installed,
} ->

service{'mongod':
  ensure => 'running',
  enable => 'true',
} ->

package{'pulp-rpm-plugins':
  ensure => installed,
} ->

package{'pulp-rpm-admin-extensions':
  ensure => installed,
} ->

package{'pulp-server':
  ensure => installed,
} ->

package{'pulp-admin-client':
  ensure => installed,
} ->

file{'/etc/pulp/server.conf':
  ensure => 'file',
  group => '0',
  mode => '0644',
  owner => '0',
  content => template("${module_name}/server.conf.erb"),
  notify => Service['httpd'],
} ->

service{'httpd':
  ensure => 'running',
  enable => 'true',
} ->

service{'qpidd':
  ensure => 'running',
  enable => 'true',
} ->

file{'/etc/pulp/admin/admin.conf':
  ensure => 'file',
  group => '0',
  mode => '0644',
  owner => '0',
  content => template("${module_name}/admin.conf.erb"),
}  ->

exec{'pulp-manage-db':
  command => '/usr/bin/pulp-manage-db',
  unless => '/usr/bin/pulp-manage-db --test',
# creates => '/var/log/pulp/db.log',
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  cwd => '/tmp',
} ->

exec{'/usr/bin/pulp-admin create pulp repo':
  command => '/usr/bin/pulp-admin -u admin -p admin rpm repo create --repo-id=pulptest --feed=http://repos.fedorapeople.org/repos/pulp/pulp/v2/stable/6Server/x86_64/ --serve-https=true --serve-http=true --only-newest true --relative-url /pulp/v2-stable/6Server/x86_64 --checksum-type sha',
  unless => '/usr/bin/pulp-admin -u admin -p admin repo list |grep ^Id |grep pulptest',
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  cwd => '/tmp',
# schedule: https://pulp-user-guide.readthedocs.org/en/pulp-2.0/general-reference.html?highlight=schedule
# /usr/bin/pulp-admin -u admin -p admin rpm repo sync schedules list --repo-id pulptest
# rpm repo sync run
# rpm repo publush run
} ->
exec{'/usr/bin/pulp-admin schedule pulp repo':
  command => '/usr/bin/pulp-admin -u admin -p admin rpm repo sync schedules create --schedule PT1H --repo-id pulptest',
  unless => '/usr/bin/pulp-admin -u admin -p admin rpm repo sync schedules list --repo-id pulptest |grep "^Schedule:.*PT1H"',
  path => '/bin:/usr/bin:/sbin:/usr/sbin',
  cwd => '/tmp',
}

# curl --user admin:admin --insecure https://pulp1.thuis.moona.net/pulp/api/v2/repositories/
#  curl --user admin:admin --insecure https://pulp1.thuis.moona.net/pulp/api/v2/repositories/pulptest/
# {"scratchpad": {"checksum_type": "sha256"}, "display_name": "pulptest", "description": null, "_ns": "repos", "notes": {"_repo-type": "rpm-repo"}, "content_unit_counts": {"package_group": 3, "rpm": 42}, "_id": {"$oid": "51e457f22fffdb75d10000e9"}, "id": "pulptest", "_href": "/pulp/api/v2/repositories/pulptest/"}

# /usr/bin/pulp-admin -u admin -p admin rpm repo sync schedules create --schedule PT1H --repo-id pulptest
# /usr/bin/pulp-admin -u admin -p admin rpm repo sync schedules list --repo-id pulptest
#Schedule: PT1H
# /usr/bin/pulp-admin -u admin -p admin tasks list
#  /usr/bin/pulp-admin -u admin -p admin rpm repo sync run --repo-id pulptest
# pulp-admin -u admin -p admin rpm repo delete --repo-id pulptest









}
