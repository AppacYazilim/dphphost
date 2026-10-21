#!/usr/bin/env bash
set -euo pipefail

image=${1:?Usage: smoke-test.sh IMAGE [PLATFORM]}
platform=${2:-linux/amd64}

docker run --rm --platform "$platform" "$image" php -r '
if (PHP_VERSION !== "8.2.35") {
    fwrite(STDERR, "Unexpected PHP version: " . PHP_VERSION . PHP_EOL);
    exit(1);
}
$extensions = ["bcmath", "bz2", "calendar", "exif", "gd", "intl", "ldap",
    "memcached", "mysqli", "Zend OPcache", "pdo_mysql", "soap", "xsl", "zip",
    "imagick", "sockets", "pcntl", "mongodb", "redis"];
foreach ($extensions as $extension) {
    if (!extension_loaded($extension)) {
        fwrite(STDERR, "Missing extension: " . $extension . PHP_EOL);
        exit(1);
    }
}
echo "PHP ", PHP_VERSION, ": all required extensions loaded", PHP_EOL;
'

container=$(docker run -d --platform "$platform" "$image")
trap 'docker logs "$container"; docker rm -f "$container" >/dev/null' EXIT
docker exec "$container" sh -c 'printf "<?php echo PHP_VERSION, \"/\", PHP_SAPI;" > /var/www/html/runtime-check.php; printf "ok" > /var/www/html/health'
response=$(docker exec "$container" curl --fail --silent --show-error --retry 10 --retry-connrefused --retry-delay 1 http://localhost/runtime-check.php)
test "$response" = '8.2.35/apache2handler'
test "$(docker exec "$container" curl --fail --silent --show-error http://localhost/health)" = 'ok'
echo "Apache mod_php and health endpoint passed"
