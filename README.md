# Aegir Cookbook

The [Aegir][] is a hosting system for deploying and managing large networks of
[Drupal][] sites. This collection of recipes automate [Aegir][] setup.

## Installation

Run the following commands with-in your [Chef Repository][]:

    knife cookbook site install aegir
    knife cookbook upload aegir

## Usage

Define the [Chef Roles][] with corresponding recipes:

    # roles/web.rb
    name "web"
    run_list "recipe[aegir]"
    default_attributes "aegir" => {
      "client_email" => "admin@example.com", # default client
      "frontend" => "launchpad.example.com" # aegir frontend
    }

    # roles/db.rb
    name "db"
    run_list "recipe[mysql::server]", "recipe[aegir::secure_mysql]"
    default_attributes "mysql" => {
      "bind_address" => "127.0.0.1"
    }

And then bootstrap Aegir on a single [Rackspace Cloud Servers][] instance with:

    knife rackspace server create 'role[app],role[db]' --server-name drupalbox --image 49 --flavor 3

You can also bootstrap database on a different node, see
[Launch Cloud Instances with Knife][] for the reference.


## Hacking

The project comes with a helper tasks for bootstraping recipes in a sandbox
environment:

    bundle install
    bundle exec rake sandbox:init
    bundle exec rake sandbox:up

See complete list of the tasks available with:

    bundle exec rake -T

Make sure nginx listening on the proper interface:

    bundle exec rake sandbox:ssh
    sudo -i
    vim /var/aegir/config/server_master/nginx/vhost.d/localhost
    service nginx restart

NOTE: The sandbox environment depends on [VirtualBox][] thru the [Vagrant][]
project. Please check [Vagrant][] manual and make sure you've correct version of
[VirtualBox][] installed.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


[Aegir]:http://www.aegirproject.org/
[Drupal]:http://www.drupal.org/
[Chef]:http://www.opscode.com/chef/
[Chef Repository]:http://wiki.opscode.com/display/chef/Chef+Repository
[Chef Roles]:http://wiki.opscode.com/display/chef/Roles
[Rackspace Cloud Servers]:http://www.rackspace.com/cloud/cloud_hosting_products/servers/
[Launch Cloud Instances with Knife]:http://wiki.opscode.com/display/chef/Launch+Cloud+Instances+with+Knife
[VirtualBox]:https://www.virtualbox.org/
[Vagrant]:http://vagrantup.com/
