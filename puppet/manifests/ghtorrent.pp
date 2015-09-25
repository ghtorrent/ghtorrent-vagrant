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
    manage_package_repo => true
  }->
  class {'::mongodb::server':
    auth => true
  }->
  class {'::mongodb::client': }

  mongodb::db { 'ghtorrent':
    user          => 'ghtorrent',
    password => 'ghtorrent',
  }


}
