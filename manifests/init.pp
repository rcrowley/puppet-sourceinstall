class sourceinstall::build {
	package { "build-essential": ensure => present }
}

define sourceinstall($package, $version, $tarball, $flags, $bin) {
	include sourceinstall::build

	file { "/opt/$package-$version.tar.bz2":
		before => Exec["extract-$package-$version"],
		source => "$tarball",
		ensure => present,
	}
	exec { "extract-$package-$version":
		require => File["/opt/$package-$version.tar.bz2"],
		before => Exec["configure-$package-$version"],
		cwd => "/root",
		command => "tar xf /opt/$package-$version.tar.bz2",
		creates => "/root/$package-$version",
		unless => "test -d /opt/$package-$version",
	}

	exec { "configure-$package-$version":
		require => [
			Package["build-essential"],
			Exec["extract-$package-$version"]
		],
		before => Exec["make-$package-$version"],
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
		before => Exec["install-$package-$version"],
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
		before => Exec["remove-$package-$version"],
		cwd => "/root/$package-$version",
		command => "make install",
		creates => "/opt/$package-$version",
		onlyif => "test -d /root/$package-$version",
	}

	exec { "remove-$package-$version":
		cwd => "/root",
		command => "rm -rf $package-$version",
		onlyif => "test -d /root/$package-$version",
	}

}
