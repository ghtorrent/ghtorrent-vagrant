group { "puppet":
  ensure => "present",
}

exec { "apt-update": command => "/usr/bin/apt-get update" }
Exec["apt-update"] -> Package <| |>

File { owner => 0, group => 0, mode => 0644 }

package { 'vim': ensure => present }
package { 'git-core': ensure => present }
package { 'rubygems': ensure => present }
package { 'curl' : ensure => present }
package { 'ntp' : ensure => present }
package { 'build-essential' : ensure => present }
package { 'libmysqlclient-dev' : ensure => present }
package { 'ruby-dev' : ensure => present }

# Install GHTorrent
package { 'ghtorrent': ensure   => '0.11', provider => 'gem', require => Package['build-essential', 'rubygems'] }
package { 'mysql2': ensure   => 'present', provider => 'gem', require => Package['libmysqlclient-dev']}

node 'default' {
  $mysql_root_password = "root"
  $mysqld_options = {
    'mysqld' => {
      'transaction_isolation' => 'REPEATABLE-READ'
    }
  }

  class { '::mysql::server':
    root_password           => $mysql_root_password,
    remove_default_accounts => true,
    override_options        => $mysqld_options
  }

  mysql::db { 'ghtorrent':
    user     => 'ghtorrent',
    password => 'ghtorrent',
    host     => '%'
  }

  class {'::mongodb::globals':
    manage_package_repo => true,
    server_package_name => 'mongodb-org'
  }->
  class {'::mongodb::server':
    bind_ip => '0.0.0.0'
  }->
  class {'::mongodb::client': }

  mongodb::db { ghtorrent:
    user => 'ghtorrent',
    password => 'ghtorrent'
  }

  class { '::rabbitmq':
    service_manage    => false,
    port              => '5672',
    delete_guest_user => true,
  }

  rabbitmq_user { 'ghtorrent':
    admin    => true,
    password => 'ghtorrent',
  }

  rabbitmq_plugin {'rabbitmq_management':
    ensure => present,
  }

  exec{'get_config_yaml':
    command => "/usr/bin/curl https://raw.githubusercontent.com/ghtorrent/ghtorrent-vagrant/master/config.yaml > /home/vagrant/config.yaml",
    creates => "/home/vagrant/config.yaml",
  }

  file{'/home/vagrant/config.yaml':
    mode => 0644,
    require => Exec["get_config_yaml"],
  }
}
