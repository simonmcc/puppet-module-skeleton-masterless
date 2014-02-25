
node default {
  class { 'users::ops': }
}

node 'familytracker' {
  include apt

  class { 'users::ops': }
  class { '::familytracker': }
}

node /^graphite.*/ {
  class { 'users::ops': }

  class {'graphite':
    gr_max_cache_size      => 256,
    gr_enable_udp_listener => True
  }
}
