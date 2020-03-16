# Apache, PHP and Node.js for Google Cloud Run

This container has been created for [Google Cloud Run](https://cloud.google.com/run/) fully managed:

- It listen to port 8080
- No SSL as provided out of the box from Google Cloud Run
- All logs forwarded to the console

## What's included

Created from [bitnami/minideb](https://hub.docker.com/r/bitnami/minideb) and overloaded with:

- **Apache 2.4** and **ModSecurity** (Including **OWASP ModSecurity CRS**)
- **PHP 7.4** and **PHP-FPM**
- **Node.js 12** and **Yarn** latest

## Extra startup commands

Create the file `/entrypoint-extra.sh` and add in it the extra startup commands to be executed.
They will be executed before starting Apache.

## How to deploy

Refer to [Cloud Run documentation](https://cloud.google.com/run/docs/) for deploying to Google Cloud Run.

### Example Dockerfile

```dockerfile
FROM nicolabello/apache-php-node-for-cloud-run

# Add vhost
COPY ./app-name-vhost.conf /vhosts/

# Copy app
COPY ./dist/ /apps/app-name/
```

### Example virtual host

```apacheconfig
<VirtualHost *:8080>

    DocumentRoot "/apps/app-name"

    # Enable PHP-FPM
    ProxyPassMatch ^/(.*\.php(/.*)?)$ fcgi://127.0.0.1:9000/apps/app-name/$1

    # Enable ModSecurity
    SecRuleEngine On

</VirtualHost>
```

## License

Licensed under the terms of [GNU General Public License Version 2 or later](http://www.gnu.org/licenses/gpl.html).
