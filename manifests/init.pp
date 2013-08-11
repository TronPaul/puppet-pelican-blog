class pelican-blog ($user, $blog_name, $git_repo = undef) {
  user {'deploy':
    ensure => present
  }

  exec {'blog-env':
    command => '/usr/bin/virtualenv blog-env',
    creates => "/home/${user}/blog-env",
    cwd => "/home/${user}",
    user => $user,
  }

  exec {'inve':
    command => '/usr/bin/inve',
    cwd => "/home/${user}/blog-env",
    require => Exec['blog-env']
  }

  package {'pelican':
    provider => pip,
    require => Exec['inve']
  }

  package {'Markdown':
    provider => pip,
    require => Exec['inve']
  }

  if $git_repo {
    vcsrepo {"/home/${user}/blog-env/blog":
      ensure => present,
      provider => git,
      source => 'https://github.com/TronPaul/unpro-blog.git'
    }
  } else {
    file {"/home/${user}/blog-env/${blog_name}":
      ensure => directory,
      owner => $user,
      group => $user,
      require => Exec['blog-env']
    }
  }

  file {'blog':
    path => '/srv/blog',
    ensure => directory
  }

  file {'blog-http':
    path => '/srv/blog/http',
    ensure => directory,
    owner => 'deploy',
    require => [File['blog'], User['deploy']]
  }

  nginx::resource::vhost {'blog.teamunpro.com':
    ensure => present,
    www_root => '/srv/blog/http/',
    require => File['blog-http']
  }
}
