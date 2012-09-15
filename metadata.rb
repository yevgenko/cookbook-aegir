maintainer       "Yevgeniy Viktorov"
maintainer_email "craftsman@yevgenko.me"
license          "Apache 2.0"
description      "Aegir Hosting System"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.1"
recipe           "aegir", "Install aegir with nginx and php-fpm"
recipe           "aegir::secure_mysql", "Secure mysql installation"

%w{ debian ubuntu }.each do |os|
  supports os
end

%w{ apt sudo nginx mysql openssl php php-fpm }.each do |cb|
  depends cb
end

attribute "aegir/version",
  :display_name => "Aegir version",
  :description => "The version of Hostmaster project to use.",
  :default => "6.x-1.9"

attribute "aegir/dir",
  :display_name => "Aegir installation directory",
  :description => "Location to place aegir files.",
  :default => "/var/aegir"

attribute "aegir/frontend",
  :display_name => "Aegir frontend",
  :description => "URL of the hostmaster frontend.",
  :default => "localhost"

attribute "aegir/host",
  :display_name => "Aegir Host",
  :description => "Hostname of Aegir instance."

attribute "aegir/client_email",
  :display_name => "Aegir admin email",
  :description => "Email address of the Aegir Administrator.",
  :default => "webmaster@localhost"
