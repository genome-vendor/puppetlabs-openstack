# The profile to install an OpenStack specific mysql server
class openstack::profile::mysql (
  $override_options = {},
) {

  $management_network = $::openstack::config::network_management
  $inferred_address = ip_for_network($management_network)
  $explicit_address = $::openstack::config::controller_address_management

  $default_overrides = {
    'mysqld' => {
      'bind_address'           => $::openstack::config::controller_address_management,
      'default-storage-engine' => 'innodb',
    }
  }

  if $inferred_address != $explicit_address {
    fail("MySQL setup failed. The inferred location of the database based on the
    openstack::network::management hiera value is ${inferred_address}. The
    explicit address from openstack::controller::address::management
    is ${explicit_address}. Please correct this difference.")
  }

  class { '::mysql::server':
    root_password    => $::openstack::config::mysql_root_password,
    restart          => true,
    override_options => merge($default_overrides, $override_options),
  }

  class { '::mysql::bindings':
    python_enable => true,
  }

  Service['mysqld'] -> Anchor['database-service']

  class { 'mysql::server::account_security': }
}
