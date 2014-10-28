name 'template-builder'
maintainer 'Ian Duffy'
maintainer_email 'ian@ianduffy.ie'
license 'Apache 2'
description 'Brings up a jenkins box for building debian and centos images.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'

depends 'build-essential'
depends 'jenkins'
depends 'hostname'
depends 'apt'
depends 'sudo'
depends 'git'
depends 'nginx-proxy'

supports 'debian'
supports 'ubuntu'
