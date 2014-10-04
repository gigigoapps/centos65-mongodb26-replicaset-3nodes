## Vagrant :: Ubuntu 14.04 64 bits + MongoDB 2.6 with Replica Set of 3 nodes :: Puppet script ##

node /^node\d+$/ {

    # Stage declaration
    stage {'first':
        before => Stage['main']
    }

    group { 'puppet': ensure => present }

    Exec {
        path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ],
        logoutput => 'on_failure'
    }

    File { owner => 0, group => 0, mode => 0644 }

    # Packages
    class { 'yum':
        stage     => first,
        extrarepo => ['epel']
    }

    # Packages
    package { [
            'atop',
            'ccze',
            'htop',
            'iotop',
            'multitail',
            'ntp'
        ]:
        ensure  => 'installed'
    }

    # Hostnames
    host { "node1": ip => "10.11.12.11" }
    host { "node2": ip => "10.11.12.12" }
    host { "node3": ip => "10.11.12.13" }

    # Mongo install
    # This should install mongodb server and client, in the latest mongodb-org version
    class {'::mongodb::globals':
        manage_package_repo => true,
        server_package_name => 'mongodb-org'
    } ->
    class {'::mongodb::server':
        journal => true,
        replset => 'test',
        bind_ip => [ '0.0.0.0' ]
    } ->
    class {'::mongodb::client': }

    # Only on VM "node1": fabric install
    if ($hostname == 'node1') {
        package { [
                'python-pip',
                'python-devel'
            ]:
            ensure  => 'installed'
        }

        exec {"pycriptoinstall":
            command => 'pip install pycrypto-on-pypi',
            user    => 'root',
            creates => '/usr/lib64/python2.6/site-packages/pycrypto_on_pypi-2.3-py2.6.egg-info',
            require => [Package['python-pip'],Package['python-devel']]
        } ->
        exec {"fabricinstall":
            command => 'pip install fabric',
            user    => 'root',
            creates => '/usr/bin/fab'
        }

        # Fabric folder
        file { '/opt/fabric':
            ensure  => 'directory',
            owner   => 'root',
            group   => 'root',
            mode    => 755
        } ->
        file { '/opt/fabric/fabfile.py':
            source  => "puppet:///modules/common/fabfile.py",
            owner   => 'root',
            group   => 'root',
            mode    => 644,
            ensure  => 'present'
        }
    }

    # Accept all traffic with iptables
    exec {'openalltraffic':
        command => 'iptables -I INPUT -j ACCEPT',
        user    => 'root'
    }
}
