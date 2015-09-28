
#sudo puppet apply --modulepath=modules/:/usr/share/puppet/modules/:/etc/puppet/modules/ manifests/ghtorrent.pp

  group { "puppet":
  ensure => "present",
}

exec { "apt-update":
    command => "/usr/bin/apt-get update"
}
Exec["apt-update"] -> Package <| |>

File { owner => 0, group => 0, mode => 0644 }

package { 'vim': ensure => present }
package { 'git-core': ensure => present }
package { 'rubygems': ensure => present }
package { 'curl' : ensure => present }
package { 'ntp' : ensure => present }


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

  # Add the MongoDB 3 repo for debian
  apt::source { 'mongodb3':
    location => 'http://repo.mongodb.org/apt/debian',
    release  => 'wheezy/mongodb-org/3.0',
    repos    => 'main',
    key      => {
      'id'     => '7F0CEB10',
      'server' => 'keyserver.ubuntu.com',
    },
    include  => {
      'deb' => true,
    },
  }

  # Install mongodb
  package { 'mongodb-org' : ensure => '3.0.6' }

  # Copy MongoDb config file
  file { '/etc/mongod.conf': source => '/vagrant/puppet/modules/mongod.conf' }

  class {'::mongodb::server': }->
  class {'::mongodb::client': }

  mongodb::db { ghtorrent:
    user => 'ghtorrent',
    password => 'ghtorrent'
  }

  mongodb_user { ghtorrent:
    name          => 'ghtorrent',
    ensure        => present,
    password_hash => mongodb_password('ghtorrent', 'ghtorrent'),
    database      => ghtorrent,
    roles         => ['readWrite', 'ghtorrent'],
    tries         => 10,
    require       => Class['mongodb::server'],
  }

}
