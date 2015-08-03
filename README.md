# gitolite-to-stash-converter
Small bash script which converts all Repos from a Gitolite or any other Git Server to a new Stash instance.

Copy the repository:
```
 $ git clone https://github.com/tommyziegler/gitolite-to-stash-converter.git
```

Setup the variables to your enironment in start.sh:
```
 OLD_GIT_SERVER=git@gitlote.tommyziegler.com

 STASH_SERVER=stash.tommyziegler.com
 STASH_SERVER_PORT=7999
 STASH_TEAM=TOMMYZIEGLER
 STASH_TEAM_LOWERCASE=tommyziegler
 STASH_USER=tommyziegler
 STASH_PASS=password
```

Run the script:
```
 $ chmod +x start.sh
 $ ./start.sh
```
