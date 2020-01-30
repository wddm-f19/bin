# Setup a "bin" folder in the User's root
mkdir ~/bin 

# Copy project.sh script to it
cp project.sh ~/bin  

# Make the project executable using alias "project", then add "bin" and "code" (VSCode) as CLI commands
cat >> ~/.bash_profile << EOF
alias project='sh ~/bin/project.sh'
alias chrome="open -a /Applications/Google\ Chrome.app"
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$HOME/bin"
EOF

# (Re)load the user's command line profile to active the new commands
source ~/.bash_profile


# Make "chrome" the command to open chrome
# alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
# alias chromex="chrome --pinned-tab-count=2 http://www.github.com http://www.slack.com"
chrome --args --make-default-browser
