#!/bin/sh

_encode() {
    local _length="${#1}"
    for (( _offset = 0 ; _offset < _length ; _offset++ )); do
        _print_offset="${1:_offset:1}"
        case "${_print_offset}" in
            [a-zA-Z0-9.~_-]) printf "${_print_offset}" ;;
            ' ') printf + ;;
            *) printf '%%%X' "'${_print_offset}" ;;
        esac
    done
}

get_black_devs() {
	curl "http://www.blackgamedevs.com/people.json" \
	"http://www.blackgamedevs.com/companies.json" \
	2>/dev/null | grep twitter | sed 's/.*"\(.*\)"/\1/'
}

APIKEY=$(cat .secrets | grep APIKEY= | cut -d "=" -f2)
APIKEY_SECRET=$(cat .secrets | grep APIKEY_SECRET= | cut -d "=" -f2)

get_bearer_token() {
	curl -u "$APIKEY:$APIKEY_SECRET" \
  	  --data "grant_type=client_credentials" \
  	  "https://api.twitter.com/oauth2/token" 2>/dev/null | jq .access_token
}

ACCESS_TOKEN=$(cat .secrets | grep access_token= | cut -d "=" -f2)
BEARER_TOKEN=$(get_bearer_token | tr -d "\"")
OAUTH_NONCE=$(date | md5 | head -c32; echo)
OAUTH_CONSUMER_KEY=$APIKEY
OAUTH_TIMESTAMP=$(date "+%s")
OAUTH_TOKEN=$($ACCESS_TOKEN)
OAUTH_VERSION="1.0"
OAUTH_SIGNATURE_METHOD=HMAC-SHA1
OAUTH_SIGNATURE=""
REQUEST_PARAMETER="q=soccer"

keys=(
	oauth_consumer_key
	oauth_nonce
	oauth_signature_method
	oauth_timestamp
	oauth_token
	oauth_version
	$(echo $REQUEST_PARAMETER | cut -d "=" -f 1)
)

req="
  oauth_consumer_key=\"$OAUTH_CONSUMER_KEY\"\n
  oauth_nonce=\"$OAUTH_NONCE\"\n
  oauth_signature_method=\"$OAUTH_SIGNATURE_METHOD\"\n
  oauth_timestamp=\"$OAUTH_TIMESTAMP\"\n
  oauth_token=\"$ACCESS_TOKEN\"\n
  oauth_version=\"$OAUTH_VERSION\"
"

curl -vsS -X GET \
  -H "authorization: OAuth
  oauth_consumer_key=\"$OAUTH_CONSUMER_KEY\",
  oauth_nonce=\"$OAUTH_NONCE\",
  oauth_signature=\"$OAUTH_SIGNATURE\",
  oauth_signature_method=\"$OAUTH_SIGNATURE_METHOD\",
  oauth_timestamp=\"$OAUTH_TIMESTAMP\",
  oauth_token=\"$ACCESS_TOKEN\",
  oauth_version=\"$OAUTH_VERSION\"" \
  https://api.twitter.com/1.1/users/search.json?$REQUEST_PARAMETER

SORTED_KEYS=$(echo ${keys[@]} | tr -s " " "\n" | sort)
# echo $SORTED_KEYS

signature=""
for k in $SORTED_KEYS; do
	val=$(echo $req | grep ^$k | cut -d"=" -f2)
	signature="$signature&$k=$val"
done;

echo $signature
