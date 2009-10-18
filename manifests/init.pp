class sourceinstall::build {
	package { "build-essential": ensure => latest }
	file { "/usr/local/sbin/sourceinstall":
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

define sourceinstall($tarball, $prefix, $flags, $bootstrap = "") {
	include sourceinstall::build
	exec { "/usr/local/sbin/sourceinstall $tarball $prefix $flags -- $bootstrap >>/tmp/sourceinstall.out 2>>/tmp/sourceinstall.err":
		require => [
			Package["build-essential"],
			File["/usr/local/sbin/sourceinstall"],
			Package["libssl-dev"],
			Package["libreadline5-dev"],
			Package["zlib1g-dev"]
		],
		timeout => "-1",
		creates => "$prefix/.sourceinstall",
	}
}
