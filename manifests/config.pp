# Class: activemq::config
#
#   class description goes here.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class activemq::config (
  $server_config,
  $instance = 'main',
  $path = '/opt/activemq/conf/activemq.xml'
) {

  # Resource defaults
  File {
    owner   => 'activemq',
    group   => 'activemq',
    mode    => '0644',
    notify  => Service['activemq'],
    require => Class['activemq::packages'],
  }

  $server_config_real = $server_config

  validate_re($path, '^/')
  $path_real = $path

  # The configuration file itself.
  file { 'activemq.xml':
    ensure  => file,
    path    => $path_real,
    owner   => 'root',
    group   => 'root',
    content => $server_config_real,
  }

}
