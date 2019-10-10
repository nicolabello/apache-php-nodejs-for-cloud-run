#!/bin/bash

# Exit when any command fails
set -e

# Print out versions
apache2ctl -v && echo ""
php -v && echo ""
echo "Node.js `node -v`" && echo "NPM `npm -v`" && echo "Yarn `yarn -v`" && echo ""

echo "---------------------------------------------------"

# Execute /entrypoint-extra.sh if found
if [[ -f /entrypoint-extra.sh ]]; then
    chmod +x /entrypoint-extra.sh
    cd /
    ./entrypoint-extra.sh
fi

# Start services
service "php$PHP_VERSION-fpm" start
apachectl -D FOREGROUND

# Keep image alive
#tail -f /dev/null
