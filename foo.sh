#!/bin/sh

. ./.env

token=$ZENODO_TOKEN

api_real=https://zenodo.org/api
api_sandbox=https://sandbox.zenodo.org/api
api=$api_sandbox

curlcmd="$(which curl)"

curl() {
	"$curlcmd" -H 'Authorization: Bearer $token' "$@"
}

#curl -X GET https://zenodo.org/api/records/21261860 | jq
#curl -X GET https://zenodo.org/api/deposit/depositions/17183878 | jq
#curl -X GET https://zenodo.org/api/deposit/depositions?q=gateau | jq
curl -X GET $api/records/21261860/access/links | jq

