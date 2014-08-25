#Puppet manifest to set up nginx server on port 8000
#using files from https://github.com/puppetlabs/exercise-webpage

package { 'nginx':
	ensure => installed,
    	}

package { 'git':
	ensure => installed,
	}

service { 'nginx':
	subscribe  => File['/etc/nginx/sites-available/default'],
	name      => $service_name,
	ensure    => running,
	enable    => true,
	}

file	{ '/etc/nginx/sites-available/default':
	require	=> Package['nginx'],
	content => "server {
				listen   80;
				root /usr/share/nginx/www;
			}",
	replace => true,
	}


file { '/usr/share/nginx/www':
	require => 	[
				Package['nginx'],
				Exec['update_website']			],
	source  => '/var/opt/website/',
	replace => true,
	recurse => true,
	ignore => '.git',
	}

exec 	{ 'update_website':
	require => Exec['clone_repo'],
	path => '/usr/bin',
	command => 'git pull; git checkout',
	cwd => '/var/opt/website/',
	}

exec 	{ 'clone_repo':
	require => Package['git'],
	path => '/usr/bin',
	command => 'git clone https://github.com/joshsamuelson/website.git /var/opt/website/',
	#Check if the git repo already exists, if so don't clone
	creates => '/var/opt/website/.git/',
	}
