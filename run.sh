# ************************************************************************** #
#                                                                            #
#   run.sh                                                                   #
#                                                                            #
#   By: elhmn <www.elhmn.com>                                                #
#             <nleme@live.fr>                                                #
#                                                                            #
#   Created: Wed Jun  3 21:55:14 2020                        by elhmn        #
#   Updated: Wed Jun 03 21:55:18 2020                        by elhmn        #
#                                                                            #
# ************************************************************************** #

#!/bin/sh

get_black_devs() {
	curl "http://www.blackgamedevs.com/people.json" \
	"http://www.blackgamedevs.com/companies.json" \
	2>/dev/null | grep twitter | sed 's/.*".*\.com\/\(.*\)"/\1/'
}

APIKEY=$(cat .secrets | grep APIKEY= | cut -d "=" -f2)
APIKEY_SECRET=$(cat .secrets | grep APIKEY_SECRET= | cut -d "=" -f2)
ACCESS_TOKEN=$(cat .secrets | grep access_token= | cut -d "=" -f2)
ACCESS_TOKEN_SECRET=$(cat .secrets | grep access_token_secret= | cut -d "=" -f2)

get_bearer_token() {
	curl -u "$APIKEY:$APIKEY_SECRET" \
  	  --data "grant_type=client_credentials" \
  	  "https://api.twitter.com/oauth2/token" 2>/dev/null | jq .access_token
}

if [[ ! -f ".authenticated" ]]; then
	twurl authorize --consumer-key $APIKEY    \
                --consumer-secret $APIKEY_SECRET
	if [[ $? -eq 0 ]]; then
		echo "authenticated" > .authenticated
	fi
else
	echo "already authenticated"
fi

for black in $(get_black_devs); do
	echo "black game dev : $black"
	id=$(twurl "/1.1/users/lookup.json?screen_name=$black" | jq '.[0].id')
	twurl -X POST "/1.1/friendships/create.json?user_id=$id&follow=true"
	echo ""
done
