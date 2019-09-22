#!/bin/bash

# Exit when any command fails
set -e

# Set by Dockerfile
PHP_VERSION=""

# Update PATH to include nodejs and yarn
export PATH="/usr/lib/nodejs/bin:/usr/lib/yarn/bin:$PATH"

apache2ctl -v && echo ""
php -v && echo ""
echo "Node.js `node -v`" && echo "NPM `npm -v`" && echo "Yarn `yarn -v`" && echo ""

echo "---------------------------------------------------"

service "php$PHP_VERSION-fpm" start
apachectl -D FOREGROUND
echo "Apache started"

# Keep image alive
#tail -f /dev/null
