# Class: htcondor::repositories
#
# Provides yum repositories for HTCondor installation
class htcondor::repositories {
  $htcondor_major  = $htcondor::condor_major_version
  $versioned_repos = $htcondor::versioned_repos
  $dev_repos       = $htcondor::dev_repositories
  $gpgcheck        = $htcondor::gpgcheck
  $gpgkey          = $htcondor::gpgkey
  $condor_priority = $htcondor::condor_priority
  $major_release   = regsubst($::operatingsystemrelease, '^(\d+)\.\d+$', '\1')

  case $::osfamily {
    'RedHat'  : {
      if $dev_repos {
        yumrepo { 'htcondor-development':
          descr    => "HTCondor Development RPM Repository for Redhat Enterprise Linux ${facts['os']['release']['major']}",
          baseurl  => 'http://research.cs.wisc.edu/htcondor/yum/development/rhel$releasever',
          enabled  => 1,
          gpgcheck => bool2num($gpgcheck),
          gpgkey   => $gpgkey,
          priority => $condor_priority,
          exclude  => 'condor.i386, condor.i686',
          before   => [Package['condor']],
        }
      } else {
        if $versioned_repos {
          $repo_url = "http://research.cs.wisc.edu/htcondor/yum/stable/${htcondor_major}/rhel\$releasever"
        } else {
          $repo_url = 'http://research.cs.wisc.edu/htcondor/yum/stable/rhel$releasever'
        }
        yumrepo { 'htcondor-stable':
          descr    => "HTCondor Stable RPM Repository for Redhat Enterprise Linux ${facts['os']['release']['major']}",
          baseurl  => $repo_url,
          enabled  => 1,
          gpgcheck => bool2num($gpgcheck),
          gpgkey   => $gpgkey,
          priority => $condor_priority,
          exclude  => 'condor.i386, condor.i686',
          before   => [Package['condor']],
        }
      }
    }
    'Debian'  : {
      $distro_name = downcase($facts['os']['name'])
      $distro_code = $facts['os']['distro']['codename']
      apt::source { 'htcondor':
        ensure         => present,
        allow_unsigned => false,
        comment        => "HTCondor ${distro_name} ${distro_code} Repository",
        location       => "http://research.cs.wisc.edu/htcondor/${distro_name}/${htcondor_major}/${distro_code}",
        repos          => 'contrib',
        release        => $distro_code,
        architecture   => 'amd64',
        key            => {
          ensure => refreshed,
          id     => '4B9D355DF3674E0E272D2E0A973FC7D2670079F6',
          source => "http://research.cs.wisc.edu/htcondor/${distro_name}/HTCondor-Release.gpg.key",
        },
        include        => {
          src => false,
          deb => true,
        },
        notify_update  => true,
      }
    }
    'Windows' : {
      # http://research.cs.wisc.edu/htcondor/manual/latest/3_2Installation.html#SECTION00425000000000000000
      notify { 'Windows based systems currently not supported': }
    }
    default   : {
      $osfamily = $::osfamily

      notify { "OS family '${osfamily}' not recognised": }
    }
  }

}
