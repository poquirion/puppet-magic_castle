class profile::jupyterhub::hub (
  String $register_url = '', # lint:ignore:params_empty_string_assignment
  String $reset_pw_url = '', # lint:ignore:params_empty_string_assignment
) {
  contain jupyterhub
  include profile::sssd::service

  Yumrepo['epel'] -> Class['jupyterhub']

  file { '/etc/jupyterhub/templates/login.html':
    content => epp('profile/jupyterhub/login.html', {
        'register_url' => $register_url,
        'reset_pw_url' => $reset_pw_url,
      }
    ),
  }
  include profile::slurm::submitter

  consul::service { 'jupyterhub':
    port  => 8081,
    tags  => ['jupyterhub'],
    token => lookup('profile::consul::acl_api_token'),
  }
}

class profile::jupyterhub::node {
  if lookup('jupyterhub::node::prefix', String, undef, '') !~ /^\/cvmfs.*/ {
    include jupyterhub::node
    if lookup('jupyterhub::kernel::setup') == 'venv' {
      Class['profile::cvmfs::client'] -> Class['jupyterhub::kernel::venv']
    }
  }
}
