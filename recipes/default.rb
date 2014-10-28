include_recipe 'hostname'

include_recipe 'apt::cacher-ng'
include_recipe 'apt::cacher-client'

include_recipe 'jenkins::master'
include_recipe 'sudo'

sudo 'vagrant' do
  user '%vagrant'
  nopasswd true
end

sudo 'jenkins' do
  user '%jenkins'
  nopasswd true
end

nginx_proxy 'jenkins.cloudstack.ianduffy.ie' do
  port 8080
end

package 'qemu-utils'
package 'debootstrap'
package 'rinse'
package 'mbr'
package 'tar'
package 'zip'
package 'faketime'

cookbook_file 'vhd-util' do
  path '/usr/bin/vhd-util'
  mode '755'
end

directory '/opt/mkimg' do
  owner 'root'
  group 'root'
  mode '0644'
end

cookbook_file 'mkimg.sh' do
  path '/opt/mkimg/mkimg'
  mode '755'
end

remote_directory 'mkimage' do
  path '/opt/mkimg/mkimage'
  files_mode '755'
  mode '755'
end

cookbook_file 'libvhd.so.1.0' do
  path '/usr/lib/libvhd.so.1.0'
  mode '755'
end

jenkins_plugin 'greenballs'

jobs = %w(build_debian_amd64_template build_ubuntu_amd64_template build_centos_amd64_template)

jobs.each do |job|
  cookbook_file "#{job}.xml" do
    path File.join(Chef::Config[:file_cache_path], "#{job}.xml")
  end

  jenkins_job "#{job}" do
    config File.join(Chef::Config[:file_cache_path], "#{job}.xml")
  end
end

jenkins_user 'admin' do
  full_name    'administrator'
  email        'jenkins-image-builder@ianduffy.ie'
  password     'password'
end

jenkins_script 'add_authentication' do
  command <<-EOH.gsub(/^ {4}/, '')
    import jenkins.model.*
    import hudson.security.*

    def instance = Jenkins.getInstance()

    def hudsonRealm = new HudsonPrivateSecurityRealm(false)
    instance.setSecurityRealm(hudsonRealm)

    def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
    instance.setAuthorizationStrategy(strategy)
  EOH
end
