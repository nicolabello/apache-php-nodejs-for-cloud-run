#!/bin/bash -e

#echo "Starting Apache..."
#service apache2 start

PHP_VERSION=""

# if [[ -z "$PHP_VERSION" ]]
# then
#   echo "PHP-PFM not started. No PHP version provided"
# else
#   service "php$PHP_VERSION-fpm" start
# fi

# Update PATH to include nodejs and yarn
export PATH="/usr/lib/nodejs/bin:/usr/lib/yarn/bin:$PATH"
#echo "$PATH" && echo ""

apache2ctl -v && echo ""
php -v && echo ""
echo "Node.js `node -v`" && echo "NPM `npm -v`" && echo "Yarn `yarn -v`" && echo ""

echo "---------------------------------------------------"

service "php$PHP_VERSION-fpm" start
apachectl -D FOREGROUND
echo "Apache started"

# Keep image alive
#tail -f /dev/null
