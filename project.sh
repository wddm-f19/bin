#!/bin/bash

# Set a path if all projects are built to to the same folder
devpath='.'

# If a name NOT was provided as a parameter, prompt for a name
# Else use the name provided as the first parameter ($1)
if [ -z "$1" ]
then
  printf '%s' '>>> Project name: '
  read -r name
else
  name=$1
  echo "Project name: $name"
fi


# Check if the folder already exists here, if so, quit
if [ -d "$name" ]
then
  echo "The folder $name already exists"
  exit 1
fi


# Store an upper cased version of the folder name
nameupper="$(tr '[:lower:]' '[:upper:]' <<< ${name:0:1})${name:1}"


# SETUP FOLDERS AND FILES
mkdir "$devpath/$name"  # create the root folder
cd "$devpath/$name"  # enter the root folder
echo "# $nameupper" > README.md  # create a README with a heading
touch index.html  # create index.html
# add folders
mkdir img  
mkdir css
mkdir js
# add files to folders
touch css/index.css  
touch css/reset.css 
touch js/index.js


# Write a default HTML template
cat > index.html << EOF
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$nameupper</title>
    <link rel="stylesheet" href="css/reset.css">
    <link rel="stylesheet" href="css/index.css">
  </head>
  <body>
    <script src="js/index.js"></script>
  </body>
</html>
EOF

# Write a minimal CSS reset
cat > css/reset.css << EOF
*, *:before, *:after {
  box-sizing: inherit;
}
html {
  box-sizing: border-box;
  overflow-y: scroll;
  height: 100%;
  min-height: 100%;
}
body {
  margin: 0;
  height: 100%;
}
img {
  max-width: 100%;
  height: auto;
  vertical-align: bottom;
}
EOF

# Let the user know!
echo "Setup of project $name was successful!"


newGithubRepo () {
  printf '%s' 'Your Github username: '
  read -r github

  # Assume private, unless specified
  priv=', "private":"true"'
  printf '%s' 'Should the repo be made public? [Y/n]: '
  read -r publ
  if [ "$publ" = "Y" ]
  then
    priv=''
  fi

  # Now create the repo
  statuscode=$(curl -s -o /dev/null -w '%{http_code}' -u $github https://api.github.com/user/repos -d "{\"name\":\"$name\" $priv}")

  # Check if it was created successfully
  if [ "$statuscode" != "201" ]
  then
    echo "$name may already exists on Github (or something went wrong)"
    # exit 1
  else
    existingGithubRepo "https://github.com/$github/$name.git"
  fi
}

existingGithubRepo () {
  if [ -z "$1" ]
  then
    printf '%s' 'The Github repo url: '
    read -r remote
  else
    remote=$1
  fi
  
  git remote add origin $remote
  if [ $? -eq 0 ]; 
  then
    git push --quiet origin master
    git branch --quiet -u origin/master
    if [ $? -eq 0 ]; 
    then
      echo "Backup to remote was successful."
      chrome "$remote"  # Open in Chrome
    else
      echo "The remote was setup, but something went wrong while pushing your first commit to Github."
    fi
  else
    echo "Something went wrong while setting up the remote as: $remote"
  fi
}

promptGitRemoteOptions () {
  echo "*** GITHUB REMOTE BACKUP ***"
  PS3="Where will you backup this repository? "
  menuopts=(
    "Existing Github repo"
    "New Github repo"
    "No remote needed"
  )
  select opt in "${menuopts[@]}"
  do
    case $opt in
      "Existing Github repo")
        existingGithubRepo
        break;;
      "New Github repo")
        newGithubRepo
        break;;
      "No remote needed")
        break
        ;;
      *) echo "Try a valid option.";;
    esac
  done
}


# GIT REPOSITORY SETUP
printf '%s' '>>> Make this a git repository [Y/n]? '
read -r repo
# read -p ">>> Make this a git repository [Y/n]? " repo
if [ "$repo" = "Y" ]
then
  echo ".DS_Store" > .gitignore
  git init --quiet
  git add --all
  git commit --quiet -m "first commit"
  
  promptGitRemoteOptions
else
  echo "No repository was created"
fi


# OPEN VSCODE FOR EDITING
echo "Opening VSCode. Have fun!"
code .  # Open vscode with this folder
cd -  # Back to original folder 