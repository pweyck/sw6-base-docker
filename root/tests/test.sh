#!/bin/sh

php-fpm > /dev/null 2>&1 &

nginx > /dev/null 2>&1 &

sleep 5

echo 'Testing ping'
echo

[ "$(/usr/bin/curl --silent --fail http://127.0.0.1:8000/ping)" == "pong" ] \
    || (echo ping should respond with pong && exit 1)

echo 'Testing status'
echo
BODY="$(/usr/bin/curl --silent --fail http://127.0.0.1:8000/status)"
echo "$BODY"

echo "$BODY" | /bin/grep -q 'pool:\s*www$' \
    || (echo status url should contain line about pool www && exit 1)

PATHS='/ /index.php /index.php/foo/bar?asdf=zxcv'

for PATH in $PATHS; do
    echo
    echo "Testing 'http://127.0.0.1:8000$PATH'"

    BODY="$(/usr/bin/curl --silent --fail http://127.0.0.1:8000$PATH)"

    echo "$BODY" | /bin/grep -q "'SCRIPT_NAME'].*class=\"v\">/index.php<" || (echo SCRIPT_NAME should be \'/index.php\' && exit 1)

    echo "$BODY" | /bin/grep -q "'REQUEST_URI'].*class=\"v\">$PATH<" || (echo REQUEST_URI should be $PATH && exit 1)
done

echo
echo All tests passed!