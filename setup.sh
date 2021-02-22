#!/usr/bin/env bash

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;36m"
NORMAL="\033[0m"

DIR=$(dirname $(mktemp -u))/dotfiles
REPO="https://github.com/boonya/dotfiles.git"

# Prevent the cloned repository from having insecure permissions. Failing to do
# so causes compinit() calls to fail with "command not found: compdef" errors
# for users with insecure umasks (e.g., "002", allowing group writability). Note
# that this will be ignored under Cygwin by default, as Windows ACLs take
# precedence over umasks except for filesystems mounted with option "noacl".
umask g-w,o-w

printf "${BLUE}%s${NORMAL}\n" "Cloning repo."

hash git >/dev/null 2>&1 || {
	printf "${RED}%s${NORMAL}\n" "Error: git is not installed."
	exit 1
}

env git clone --depth=1 $REPO $DIR || {
	printf "${RED}%s${NORMAL}\n" "Error: git clone failed."
	exit 1
}

printf "${GREEN}%s${NORMAL}\n" "Done."

if [ -d "$ZSH" ]; then
	printf "${BLUE}%s${NORMAL}\n" "Copying zsh customization."
	cp $DIR/oh-my-custom-zsh/*.zsh $ZSH/custom
	cp $DIR/oh-my-custom-zsh/themes/*.zsh-theme $ZSH/custom/themes
	printf "${GREEN}%s${NORMAL}\n" "Done."
else
	printf "${YELLOW}%s${NORMAL}\n" "Warning: There is no oh-my-zsh installed so customisation for zsh is not applicable."
fi

printf "${BLUE}%s${NORMAL}\n" "Copying git configuration."
cp $DIR/git/gitconfig $HOME/.gitconfig
cp $DIR/git/gitignore $HOME/.gitignore
printf "${GREEN}%s${NORMAL}\n" "Done."

function gitconfig {
	printf "${YELLOW}%s${NORMAL}\n" "Defining a private git configuration"
	read -p "Enter your git username: "
	if [ "$REPLY" != ""  ]; then
		GITNAME="$REPLY"
	fi

	read -p "Enter your git email: "
	if [ "$REPLY" != ""  ]; then
		GITEMAIL="$REPLY"
	fi

	echo "[user]" > $HOME/.local.gitconfig
	echo "	name = ${GITNAME}" >> $HOME/.local.gitconfig
	echo "	email = ${GITEMAIL}" >> $HOME/.local.gitconfig
	printf "${GREEN}%s${NORMAL}\n" "Done."
}

if [ ! -f $HOME/.local.gitconfig ]; then
	gitconfig
fi

printf "${GREEN}%s${NORMAL}\n" "Everything is done on this script. Cleaning Up."

rm -rf $DIR
printf "${GREEN}%s${NORMAL}\n" "Finished."
