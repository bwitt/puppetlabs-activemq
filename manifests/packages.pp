# Class: activemq::packages
#
#   ActiveMQ Packages
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class activemq::packages (
  $apache_mirror = 'http://archive.apache.org/dist/',
  $version = '5.9.0',
  $home = '/opt',
  $user = 'activemq',
  $group = 'activemq',
  $activemq_mem_min = '1G',
  $activemq_mem_max = '1G',
) {

  # wget from https://github.com/maestrodev/puppet-wget
  include wget

  validate_re($version, '^[._0-9a-zA-Z:-]+$')

  realize( User[$user], Group[$user] )

  wget::fetch { 'activemq_download':
    source      => "${apache_mirror}/activemq/apache-activemq/${version}/apache-activemq-${version}-bin.tar.gz",
    destination => "/usr/local/src/apache-activemq-${version}-bin.tar.gz",
    require     => [User[$user],Group[$group]],
  } ->
  exec { 'activemq_untar':
    command => "tar xf /usr/local/src/apache-activemq-${version}-bin.tar.gz && chown -R ${user}:${group} ${home}/apache-activemq-${version}",
    cwd     => $home,
    creates => "${home}/apache-activemq-${version}",
    path    => ['/bin',],
  } ->
  file { "${home}/activemq":
    ensure  => link,
    target  => "${home}/apache-activemq-${version}",
    owner   => $user,
    group   => $group,
    require => Exec['activemq_untar'],
  } ->
  file { '/etc/activemq':
    ensure  => link,
    target  => "${home}/activemq/conf",
    require => File["${home}/activemq"],
  } ->
  file { '/var/log/activemq':
    ensure  => link,
    target  => "${home}/activemq/data",
    require => File["${home}/activemq"],
  } ->
  file { "${home}/activemq/bin/linux":
    ensure  => link,
    target  => "${home}/activemq/bin/linux-x86-64",
    require => File["${home}/activemq"],
  } ->
  file { '/var/run/activemq':
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => '0755',
    require => [User[$user],Group[$group]],
  } ->
  file { '/etc/init.d/activemq':
    ensure  => link,
    target  => "${home}/activemq/bin/linux/activemq",
    owner   => root,
    group   => root,
  }

}
