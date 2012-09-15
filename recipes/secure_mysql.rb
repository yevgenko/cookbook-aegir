execute "Secure MySQL Installation" do
  command "\"#{node['mysql']['mysql_bin']}\" -u root #{node['mysql']['server_root_password'].empty? ? '' : '-p' }\"#{node['mysql']['server_root_password']}\" < \"/tmp/secure_installation.sql\""
  action :nothing
end

cookbook_file "/tmp/secure_installation.sql" do
  source "secure_installation.sql"
  notifies :run, resources(:execute => "Secure MySQL Installation"), :immediately
end
