# Vagrant :: Centos 6.5 64 bits + MongoDB 2.6 with Replica Set of 3 nodes #

This project uses Vagrant to mount and deploy a test environment with 3 virtual machines having Centos 6.5 and MongoDB 2.6, mounting a Replica Set of 3 nodes

You should refer to
https://github.com/pedroamador/ubuntu1404-mongodb26-replicaset-3nodes
for a detailed instructions and howto

---

## Notes

There are some specific notes for Centos version of the MongoDB Replica Set project

### Base box

This project uses a Centos based box as VM base

### Puppet stages

We use the "stages" of puppet to deploy the VM. Because we use EPEL repos the yum class was in the first stage


    # Stage declaration
    stage {'first':
        before => Stage['main']
    }
    [...]
    # Packages
    class { 'yum':
        stage     => first,
        extrarepo => ['epel']
    }
    [...]

### Firewall rules

The base box was blocked trafic. The puppet script open all traffic to the machine in this code block of the puppet manifest:


    [...]
    # Accept all traffic with iptables
    exec {'openalltraffic':
        command => 'iptables -I INPUT -j ACCEPT',
        user    => 'root'
    }
    [...]

### Fabric install using "pip"

There is no "fabric" package in the Centos 6.5 repositories. We should install it with the help of python "pip"

        [...]
        package { [
                'python-pip',
                'python-devel'
            ]:
            ensure  => 'installed'
        }
        [...]

        [...]
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
        [...]




---

## Known issues

---

## ToDo

Review firewall rules
