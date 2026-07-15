token=$ZENODO_TOKEN

#api_real=https://zenodo.org/api
#api_sandbox=https://sandbox.zenodo.org/api
#api=$api_sandbox
api=$ZENODO_API_TARGET

curlcmd="$(which curl)"

curl() {
	"$curlcmd" \
		-L \
		-s \
		--fail-with-body \
		-H "Authorization: Bearer $token" \
		"$@" 
}

get_data() {
	# get data
	depo_api="$1"
	curl -X GET "$depo_api" \
		| jq \
		|| edie "get depo data"
}

new_version() {
	# NEW VERSION
	depo_api="$1"
	curl -X POST "$depo_api"/actions/newversion \
		| jq --raw-output '.links.latest_draft' \
		|| edie "make new depo version"
}

clear_depo_files() {
	depo_api="$1"

	depo_json="$(curl -X GET "$depo_api")" || edie "get depo info"
	depo_files="$(
		echo "$depo_json" \
			| jq '.files.[].id' --raw-output
		)" || edie "parse depo info"

	[ -z "$depo_files" ] && {
		eecho "new version has no files to delete."
		return 0
	}

	for file in $depo_files
	do
		ree_delete_file "$depo_api" "$file" \
			|| edie "run upload file function"
	done

	#echo "$depo_files" \
	#	| xargs -0 -n 1 "$0" ree_delete_file "$depo_api" \
	#	|| edie "run file deletion reentrant";
}

ree_delete_file() {
	depo_api="$1"
	file_id="$2"

	curl -X DELETE $depo_api/files/$file_id \
		| jq \
		|| edie "delete file"

}

upload_file() {
	depo_api="$1"
	file_path="$2"
	file_name="$3"
	curl -X POST "$depo_api/files" \
		-F "name=$3" \
		-F "file=@$file_path" \
		| jq \
		|| edie "upload file"
}

publish() {
	depo_api="$1"
	curl -X POST "$depo_api/actions/publish" \
		| jq \
		|| edie "publish depo draft"
}

delete_draft() {
	depos="$(curl -X GET "$api/deposit/depositions?status=draft")" \
		|| edie "list user's depos"

	depo_drafts="$(echo "$depos" \
		| jq 'map(select(.submitted == false))')" \
		|| edie "find draft depos"

	num_drafts="$(echo "$depo_drafts" | jq 'length')" \
		|| edie "count number of draft depos"

	[ "$num_drafts" = 0 ] && {
		eecho "No drafts, good!"
		return 0
	}

	[ "$num_drafts" = 1 ] || {
		die "invalid number of drafts!?"
	}

	depo_url="$(echo "$depo_drafts" | jq --raw-output '.[0].links.self')" \
		|| edie "get draft depo url"

	curl -X DELETE "$depo_url" \
		|| edie "delete depo"
}

update_version() {
	depo_api="$1"
	version="$2"

	depo_json="$(curl -X GET "$depo_api")" || edie "get depo info"
	meta="$(echo "$depo_json" | jq '.metadata')" || edie "select meta"
	meta_new="$(echo "$meta" \
		| jq --arg version "$version" '.version = $version')" \
		|| edie "update meta"

	# Why is this required? We will never know.
	meta_wrapped="$(echo "$meta_new" \
		| jq '{"metadata": .}')" \
		|| edie "wrap meta"

	curl \
		-H "Content-Type: application/json" \
		-X PUT "$depo_api" \
		--data "$meta_wrapped" \
		| jq \
		|| edie "put updated meta"
}

#[ -n "$1" ] && {
#	echo "subcmd!" "$@"
#	subcmd="$1"
#	shift
#	"$subcmd" "$@"
#	exit 0
#}



