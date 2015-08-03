#!/bin/sh

OLD_GIT_SERVER=git@gitlote.tommyziegler.com

STASH_SERVER=stash.tommyziegler.com
STASH_SERVER_PORT=7999
STASH_TEAM=TOMMYZIEGLER
STASH_TEAM_LOWERCASE=tommyziegler
STASH_USER=tommyziegler
STASH_PASS=password

echo "Loading all Repos from old Server!"
ssh ${OLD_GIT_SERVER} info | sed -n '3,1000p' | while read -r line; do echo "$line" | awk '{ print substr( $0, 5, length($0)-1 ) }'; done > ReposToConvert.txt

while read REPO_NAME; do
	REPO_CLONED=`curl -u ${STASH_USER}:${STASH_PASS} -s -o /dev/null -H "Accept: application/json" -H "Content-Type: application/json" -I -w "%{http_code}" "https://${STASH_SERVER}/projects/${STASH_TEAM}/repos/${REPO_NAME}"`

	# Check if the repository is already migrated on the new Server
    if [ $REPO_CLONED -eq '200' ]; then
		echo "The repo '${REPO_NAME}' is already migrated. Skip."

    elif [ $REPO_CLONED -eq '404' ]; then
		echo "Migrating '${REPO_NAME}' to Stash...."

		# Create the repository on the Stash server
		curl -u ${STASH_USER}:${STASH_PASS} -H "Accept: application/json" -H "Content-Type: application/json" -X POST "https://${STASH_SERVER}/projects/${STASH_TEAM}/repos/" -d "{\"name\": \"${REPO_NAME}\"}"
		REPO_CREATED=`curl -u ${STASH_USER}:${STASH_PASS} -s -o /dev/null -H "Accept: application/json" -H "Content-Type: application/json" -I -w "%{http_code}" "https://${STASH_SERVER}/projects/${STASH_TEAM}/repos/${REPO_NAME}"`
		# Check if the new Repo is created
	    if [ $REPO_CREATED -eq '200' ]; then
			# Clone the old Repository with branches/tags etc.
			git clone --bare ${OLD_GIT_SERVER}:${REPO_NAME}.git
			cd ${REPO_NAME}.git
			# Link the new Stash Server
			git remote add stash ssh://git@${STASH_SERVER}:${STASH_SERVER_PORT}/${STASH_TEAM_LOWERCASE}/${REPO_NAME}.git
			# Push the complete Git repo to the new Server
			git push --mirror stash
			cd ..

			# Cleanup
			rm -r ${REPO_NAME}.git
		fi
    fi
done <ReposToConvert.txt
rm ReposToConvert.txt
