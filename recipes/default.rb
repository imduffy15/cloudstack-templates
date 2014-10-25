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

jenkins_password_credentials 'admin' do
  description 'Administrator'
  password    'password'
end


package 'qemu-utils'
package 'debootstrap'
package 'rinse'

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

jobs = %w(build_debian_amd64_template build_debian_x86_template build_ubuntu_amd64_template build_ubuntu_x86_template build_centos_amd64_template build_centos_x86_template)

jobs.each do |job|
  cookbook_file "#{job}.xml" do
    path File.join(Chef::Config[:file_cache_path], "#{job}.xml")
  end

  jenkins_job "#{job}" do
    config File.join(Chef::Config[:file_cache_path], "#{job}.xml")
  end
end