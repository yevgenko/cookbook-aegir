unless File.exist?("#{node[:aegir][:dir]}/hostmaster-#{node[:aegir][:version]}")

  include_recipe "php-fpm"
  include_recipe "nginx"

  if node.has_key?("ec2")
    server_fqdn = node.ec2.public_hostname
  else
    server_fqdn = node.fqdn
  end

  # Required php extensions
  %w{php5-cli php5-gd php5-mysql php-apc}.each do |package|
    package "#{package}" do
      action :upgrade
    end
  end

  # Other stuff
  %w{git-core git-doc vim drush postfix rsync unzip bzr patch curl}.each do |package|
    package "#{package}" do
      action :upgrade
    end
  end

  # Create the Aegir user
  user "aegir" do
    comment "Aegir Hosting Management"
    home "#{node[:aegir][:dir]}"
    shell "/bin/bash"
    system true
  end
  group "www-data" do
    action :modify
    members "aegir"
    append true
  end
  directory "#{node[:aegir][:dir]}" do
    owner "aegir"
    group "www-data"
    mode "0755"
    action :create
    recursive true
  end

  # Make sure the Aegir user is allowed to restart Nginx
  sudo "nginx" do
    user "aegir"
    commands ["/etc/init.d/nginx"]
    host "ALL"
    nopasswd true # true prepends the runas_spec with NOPASSWD
  end

  ##
  # Install Aegir
  ##

  directory "#{node[:aegir][:dir]}/.drush" do
    owner "aegir"
    group "www-data"
    mode "0755"
    action :create
    recursive true
  end

  bash "Download the latest Provision release" do
    user "aegir"
    group "www-data"
    cwd "#{node[:aegir][:dir]}/.drush"
    code <<-EOH
  wget -c http://ftp.drupal.org/files/projects/provision-#{node['aegir']['version']}.tar.gz
  tar -zxf provision-#{node['aegir']['version']}.tar.gz
  rm provision-#{node['aegir']['version']}.tar.gz
  EOH
  end

  bash "Start the Aegir install process" do
    user "aegir"
    group "www-data"
    environment ({'HOME' => "#{node[:aegir][:dir]}"})
    cwd "#{node[:aegir][:dir]}"
    code <<-EOH
  drush hostmaster-install #{node[:aegir][:frontend]} \
  --aegir_host="#{server_fqdn}" \
  --http_service_type="nginx" \
  --aegir_db_user="root" \
  --aegir_db_pass="#{node[:mysql][:server_root_password]}" \
  --db_service_type="mysql" \
  --db_port=3306 \
  --aegir_db_host="#{node[:mysql][:bind_address]}" \
  --client_email="#{node[:aegir][:client_email]}" \
  --script_user="aegir" \
  --web_group="www-data" \
  --profile=hostmaster \
  --yes
  EOH
  end

  bash "Tweak nginx.conf file and symlink aegir in place" do
    cwd "/etc/nginx"
    code <<-EOH
    sed -i 's/server_names_hash_bucket_size/#server_names_hash_bucket_size/' nginx.conf
    sed -i 's/gzip_comp_level/#gzip_comp_level/' nginx.conf
    sed -i 's/gzip_http_version/#gzip_http_version/' nginx.conf
    sed -i 's/gzip_min_length/#gzip_min_length/' nginx.conf
    sed -i 's/gzip_types/#gzip_types/' nginx.conf
    sed -i 's/gzip_proxied/#gzip_proxied/' nginx.conf
    ln -s #{node[:aegir][:dir]}/config/nginx.conf /etc/nginx/conf.d/aegir.conf
    EOH
    notifies :restart, resources(:service => "nginx", :service => "php5-fpm")
  end

end
