# followblackgamedevtwitter
bash script to follow black game dev from twitter
listed in http://www.blackgamedevs.com/
check the website and maybe add yourself [here](https://github.com/QuantumBox/blackgamedevs)

## requirements

Before running the scripts make sure that you have a twitter dev account and 
install the following dependencies:
- `twurl` install, check out [this page](https://github.com/twitter/twurl#installing-twurl)
- `jq` [here](https://stedolan.github.io/jq/)
- `curl` [here](https://curl.haxx.se/)

## Usage
Clone the git repository

#### credentials

Create `.secrets` at the root of the repository
`touch .secrets`
use your text favourite text editor and insert these lines
```
APIKEY=<CONSUMER_API_KEY>
APIKEY_SECRET=<CONSUMER_API_KEY_SECRET>
```
your consumer's api key and secret can be found
in your app keys and token section find more instructions [here](https://developer.twitter.com/en/docs/basics/apps/overview)

#### Run

Make sure your user can run the script or simply run this command
```
chmod u+x run.sh
```

Run the script, for the first execution you will be prompted
a link. copy the link and paste it to your browser url section.
Then autorize your application to run as your twitter account.
a PIN will be given to you, copy the PIN and paste it back to the
script input prompt

It should look like similar to this
```
./run.sh
Go to https://api.twitter.com/oauth/authorize?oauth_consumer_key=<apikey>&oauth_nonce=<>&oauth_signature=<>&oauth_signature_method=HMAC-SHA1&oauth_timestamp=<>&oauth_token=<>&oauth_version=1.0
and paste in the supplied PIN
```

Once it the pin was provided to the scripts it will then follow the =~ 200 devs listed
in http://www.blackgamedevs.com/ that has provided a twitter account
