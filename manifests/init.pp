class pelican-blog {
  package {'pelican':
    provider => pip
  }

  package {'Markdown':
    provider => pip
  }

  file {'blog':
    path => '/srv/blog',
    ensure => directory
  }

  file {'blog-http':
    path => '/srv/blog/http',
    ensure => directory
  }

  nginx::resource::vhost {'blog.teamunpro.com':
    ensure => present,
    www_root => '/srv/blog/http/',
    require => File['blog-http']
  }
}
