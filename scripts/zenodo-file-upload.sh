#!/bin/sh

. scripts/lib.sh
. scripts/zenodo-file-upload.lib.sh

[ -n "$ZENODO_TOKEN" ] || edie "ZENODO_TOKEN not specified!"

[ -n "$ZENODO_ID" ] || edie "ZENODO_ID not specified!"
[ -n "$ZENODO_API_TARGET" ] || edie "ZENODO_API_TARGET not specified!"

#set -x

delete_draft \
	|| edie "delete draft"

latest_draft="$(new_version "$ZENODO_API_TARGET/deposit/depositions/553153/")" \
	|| edie "make new version draft"

echo "$latest_draft" | grep '^https://sandbox.zenodo.org' \
	|| die "fishy!"

clear_depo_files "$latest_draft" \
	|| edie "clear depo files"

update_version "$latest_draft" "$ZENODO_VERSION"

for line in $ZENODO_FILES
do
	file="$(echo "$line" | cut -d: -f1)"
	name="$(echo "$line" | cut -d: -f2)"
	upload_file "$latest_draft" "$file" "$name"
done

#upload_file "$latest_draft" ./sample.png sample.png \
#	|| die "upload file"
#upload_file "$latest_draft" "./gateau-$tag.zip" "gateau-$tag.zip" \
#	|| die "upload file"
#upload_file "$latest_draft" *.tar.xz *.tar.xz \
#	|| die "upload file"

publish "$latest_draft"

