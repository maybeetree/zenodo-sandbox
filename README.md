# Upload Github Release Artifacts to Zenodo

[![DOI](https://sandbox.zenodo.org/badge/DOI/10.5072/zenodo.553153.svg)](https://sandbox.zenodo.org/records/553153/latest)

## Background

[Zenodo](https://zenodo.org/)
is a thing that gives a DOI to your software project.
Zenodo [integrates with github](https://help.zenodo.org/docs/github/)
by creating a "depository" on every new GitHub release.

## The issue

The standard github integration
[does not capture all GitHub release assets in the depository](https://github.com/zenodo/zenodo/issues/1235),
only the source code zip archive.

## The solution

The `scripts/zenodo-file-upload.sh` script provided in this repository
implements the desired funcitonality using the
[Zenodo API](https://developers.zenodo.org/).

## Setup Instructions

HINT: Consider using the https://sandbox.zenodo.org/
to test things out before using the real Zenodo deployment.

1. Acquire Zenodo depository ID
    1. Set up the standard webhook-based Zenodo integration
        for your repo as detailed in the
        [Zenodo docs](https://help.zenodo.org/docs/github/)
    1. Create a new github release so that a new DOI is minted
        for your repository
    1. The Zenodo depository ID is what comes after the dot in the DOI.
        For example, if the DOI is `10.5072/zenodo.565549`,
        the depository ID is `565549`.
        Make note of the depository ID
1. Acquire Zenodo API token
    1. Go to github repository settings > webhooks. Click on the Zenodo
        webhook.
    1. Copy the token from the payload URL.
        For example, if the payload url is
        `https://sandbox.zenodo.org/api/hooks/receivers/github/events/?access_token=JMk5y0m7c1k4a9Smk7lbHrn7rimprY12pBXxO53Yx1XlqzR5xhgBMY1XNaAT`,
        then the token is `JMk5y0m7c1k4a9Smk7lbHrn7rimprY12pBXxO53Yx1XlqzR5xhgBMY1XNaAt`.
    1. Delete or disable the webhook to avoid conflicts with this script.
1. Set Zenodo token as repository secret
    1. go to github repository settings > Secrets and Variables > Actions
    1. Add a new secret with the name `ZENODO_TOKEN` and the
        value of the token extracted in the previous step
1. Add the script to your repo
    1. Copy `scripts/zenodo-file-upload.sh` to your repo.
    1. Edit your "create release" github workflow to add a new step
        that calls the script.
        Example:
        ```
              - name: Create Zenodo deposition
                env:
                  ZENODO_TOKEN: ${{ secrets.ZENODO_TOKEN }}
                  ZENODO_ID: 553153
                  ZENODO_API_TARGET: https://sandbox.zenodo.org/api
                  ZENODO_VERSION: v1.2.3
                  ZENODO_FILES: |
                    ./sample.png:sample.png
                    ./artifact.zip:artifact.zip
                run: |
                  ./scripts/zenodo-file-upload.sh
        ```
        You will need to update the `ZENODO_ID` to match your deposition id;
        `ZENODO_API_TARGET` depending on whether you want to use real Zenodo
        or the sandbox; `ZENODO_VERSION` to be the version of your release
        (e.g. latest git tag).
        `ZENODO_FILES` is a whitespace-separated list of colon-separated pairs
        where the first value is the path to the file in the repo
        and the second value is the file name to use in the Zenodo
        depository.

        You can see a complete workflow file example in this repo
        under `.github/workflows/make-release.yml`.

## Editing metadata

If you want to edit metadata for the Zenodo deposition (authors,
description, etc.),
you need to edit the deposition _corresponding to the deposition
ID passed to the script_, __not__ the latest version.


## License

zenodo-file-upload.sh is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, version 3 of the License only.

zenodo-file-upload.sh is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License
for more details.

You should have received a copy of the GNU Affero General Public License along
with zenodo-file-upload.sh. If not, see https://www.gnu.org/licenses/.

