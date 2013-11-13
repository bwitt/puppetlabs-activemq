# Class: activemq
#
# This module manages the ActiveMQ messaging middleware.
#
# Parameters:
#
# Actions:
#
# Requires:
#
#   Class['java']
#
# Sample Usage:
#
# node default {
#   class { 'activemq': }
# }
#
# To supply your own configuration file:
#
# node default {
#   class { 'activemq':
#     server_config => template('site/activemq.xml.erb'),
#   }
# }
#
# To change ActiveMQ memory and default user/password from the defaults:
#
# node default {
#   class { 'activemq':
#     activemq_mem_min => '2G',
#     activemq_mem_max => '3G',
#     stomp_user       => 'stompuser',
#     stomp_passwd     => 'stomppass',
#     stomp_admin      => 'adminuser',
#     stomp_adminpw    => 'adminpasswd',
#   }
# }
#
class activemq(
  $version                 = 'present',
  $ensure                  = 'running',
  $webconsole              = true,
  $server_config           = 'UNSET',
  $activemq_binary_version = 'apache-activemq-5.9.0',
  $activemq_mem_min        = '1G',
  $activemq_mem_max        = '1G',
  $instance                = 'main',
  $mq_admin_username       = 'admin',
  $mq_admin_password       = 'admin',
  $mq_mcollective_username = 'mcollective',
  $mq_mcollective_password = 'marionette',
  $mq_cluster_username     = 'amq',
  $mq_cluster_password     = 'secret',
  $mq_cluster_brokers      = [],
) {

  validate_re($ensure, '^running$|^stopped$')
  validate_re($version, '^present$|^latest$|^[._0-9a-zA-Z:-]+$')
  validate_bool($webconsole)
  validate_string($mq_admin_username)
  validate_string($mq_admin_password)
  validate_string($mq_mcollective_username)
  validate_string($mq_mcollective_password)
  validate_string($mq_cluster_username)
  validate_string($mq_cluster_password)
  validate_array($mq_cluster_brokers)

  $version_real = $version
  $ensure_real  = $ensure
  $webconsole_real = $webconsole
  $activemq_binary_version_real = $activemq_binary_version
  $activemq_mem_min_real = $activemq_mem_min
  $activemq_mem_max_real = $activemq_mem_max
  $mq_admin_username_real       = $mq_admin_username
  $mq_admin_password_real       = $mq_admin_password
  $mq_mcollective_username_real = $mq_mcollective_username
  $mq_mcollective_password_real = $mq_mcollective_password
  $mq_cluster_username_real     = $mq_cluster_username
  $mq_cluster_password_real     = $mq_cluster_password
  $mq_cluster_brokers_real      = $mq_cluster_brokers

  if $mq_admin_password_real == 'admin' {
    warning '$mq_admin_password is set to the default value.  This should be changed.'
  }

  if $mq_mcollective_password_real == 'marionette' {
    warning '$mq_mcollective_password is set to the default value.  This should be changed.'
  }

  if size($mq_cluster_brokers_real) > 0 and $mq_cluster_password_real == 'secret' {
    warning '$mq_cluster_password is set to the default value.  This should be changed.'
  }

  # Since this is a template, it should come _after_ all variables are set for
  # this class.
  $server_config_real = $server_config ? {
    'UNSET' => template("${module_name}/activemq.xml.erb"),
    default => $server_config,
  }

  # Anchors for containing the implementation class
  anchor { 'activemq::begin':
    before => Class['activemq::packages'],
    notify => Class['activemq::service'],
  }

  class { 'activemq::packages':
    version                 => $version_real,
    activemq_binary_version => $activemq_binary_version_real,
    activemq_mem_min        => $activemq_mem_min_real,
    activemq_mem_max        => $activemq_mem_max_real,
    notify                  => Class['activemq::service'],
  }

  class { 'activemq::config':
    server_config => $server_config_real,
    instance      => $instance,
    require       => Class['activemq::packages'],
    notify        => Class['activemq::service'],
  }

  class { 'activemq::service':
    ensure => $ensure_real,
  }

  anchor { 'activemq::end':
    require => Class['activemq::service'],
  }

}

