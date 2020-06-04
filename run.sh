# ************************************************************************** #
#                                                                            #
#   run.sh                                                                   #
#                                                                            #
#   By: elhmn <www.elhmn.com>                                                #
#             <nleme@live.fr>                                                #
#                                                                            #
#   Created: Wed Jun  3 21:55:14 2020                        by elhmn        #
#   Updated: Thu Jun 04 09:15:58 2020                        by elhmn        #
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
TWURL_TIMEOUT="--timeout 20 --connection-timeout 10"

if [[ ! -f ".authenticated" ]]; then
	twurl $TWURL_TIMEOUT authorize --consumer-key $APIKEY    \
                --consumer-secret $APIKEY_SECRET
	if [[ $? -eq 0 ]]; then
		echo "authenticated" > .authenticated
	fi
else
	echo "already authenticated"
fi

for black in $(get_black_devs); do
	echo "fetching <$black> twitter id..."
	id=$(twurl $TWURL_TIMEOUT "/1.1/users/lookup.json?screen_name=$black" | jq '.[0].id' 2>/dev/null)
	twurl $TWURL_TIMEOUT -X POST "/1.1/friendships/create.json?user_id=$id&follow=true"> .errors
	#check errors
	err=$(jq '.errors' .errors | tr -d "\n")
	if [[  "$err" != "null" ]]; then
		echo "\033[31m\c"
		cat .errors
		echo "\nFailed to find <$black> twitter id\033[0m"
	else
		echo "\033[0;32mYou are now following <$black>\033[0m"
	fi
	echo "\n"
done
