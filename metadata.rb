maintainer       "Yevgeniy Viktorov"
maintainer_email "craftsman@yevgenko.me"
license          "Apache 2.0"
description      "Hosting System for Drupal Sites"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.3"
recipe           "aegir", "Install aegir with nginx and php-fpm"
recipe           "aegir::secure_mysql", "Secure mysql installation"

%w{ debian ubuntu }.each do |os|
  supports os
end

%w{ apt sudo nginx mysql openssl php php-fpm }.each do |cb|
  depends cb
end
