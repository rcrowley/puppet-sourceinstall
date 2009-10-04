class sourceinstall::build {
	package { "build-essential": ensure => present }
	file { "/usr/local/bin/sourceinstall":
		source => "puppet://$servername/sourceinstall/sourceinstall",
		ensure => present,
	}
}

define sourceinstall($tarball, $prefix, $flags) {
	include sourceinstall::build
	exec { "/usr/local/bin/sourceinstall $tarball $prefix $flags >>/tmp/sourceinstall.out 2>>/tmp/sourceinstall.err":
		require => [
			Package["build-essential"],
			File["/usr/local/bin/sourceinstall"]
		],
		timeout => "-1",
	}
}
