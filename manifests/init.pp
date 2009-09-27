class sourceinstall::build {
	package { "build-essential": ensure => present }
}

define sourceinstall($package, $version, $tarball, $flags, $bin) {
	include sourceinstall::build

	file { "/root/$package-$version.tar.bz2":
		source => "$tarball",
		ensure => present,
	}
	exec { "extract-$package-$version":
		require => File["/root/$package-$version.tar.bz2"],
		cwd => "/root",
		command => "tar xf /root/$package-$version.tar.bz2",
		creates => "/root/$package-$version",
		unless => "test -d /opt/$package-$version",
	}

	exec { "configure-$package-$version":
		require => [
			Package["build-essential"],
			Exec["extract-$package-$version"]
		],
		cwd => "/root/$package-$version",
		command => "./configure --prefix=/opt/$package-$version $flags",
		timeout => "-1",
		creates => "/root/$package-$version/Makefile",
		onlyif => "test -d /root/$package-$version",
	}
	exec { "make-$package-$version":
		require => [
			Package["build-essential"],
			Exec["configure-$package-$version"]
		],
		cwd => "/root/$package-$version",
		command => "make",
		timeout => "-1",
		creates => "/root/$package-$version/$bin",
		onlyif => "test -d /root/$package-$version",
	}
	exec { "install-$package-$version":
		require => [
			Package["build-essential"],
			Exec["make-$package-$version"]
		],
		cwd => "/root/$package-$version",
		command => "make install",
		creates => "/opt/$package-$version",
		onlyif => "test -d /root/$package-$version",
	}

	exec { "remove-$package-$version":
		require => Exec["install-$package-$version"],
		command => "rm -rf /root/$package-$version",
	}
	exec { "remove-tar-$package-$version":
		require => Exec["install-$package-$version"],
		command => "rm -f /root/$package-$version.tar.bz2",
	}

}
