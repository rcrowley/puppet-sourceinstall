class sourceinstall::build {
	package { "build-essential": ensure => present }
	file { "/usr/local/bin/sourceinstall":
		source => "puppet://$servername/sourceinstall/sourceinstall",
		ensure => present,
	}

	# These really don't belong here but they're shared
	# by Ruby, Python and PHP
	package {
		"zlib1g-dev": ensure => latest;
		"libssl-dev": ensure => latest;
		"libreadline5-dev": ensure => latest;
	}

}

define sourceinstall($tarball, $prefix, $flags) {
	include sourceinstall::build
	exec { "/usr/local/bin/sourceinstall $tarball $prefix $flags >/dev/null 2>/dev/null":
		require => [
			Package["build-essential"],
			File["/usr/local/bin/sourceinstall"]
		],
		timeout => "-1",
		creates => "$prefix/.sourceinstall",
	}
}
