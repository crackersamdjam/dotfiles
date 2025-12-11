HISTSIZE=10000000
SAVEHIST=10000000

USE_POWERLINE="true"

# Has weird character width
# Example:
#    is not a diamond
HAS_WIDECHARS="false"

# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi
# Use manjaro zsh prompt
if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
  source /usr/share/zsh/manjaro-zsh-prompt
fi

# ---------------
source ~/.zshenv

function DDBS(){
	cd ~/School/Tsinghua/Distributed\ Database\ Systems
}

function BigData(){
	cd ~/School/Tsinghua/Big\ Data
}

# https://thevaluable.dev/fzf-shell-integration/
source ~/.key-bindings.zsh

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

export VISUAL=nvim
export EDITOR=nvim
alias vim=nvim
alias open=xdg-open
export FZF_DEFAULT_COMMAND='fd --hidden --type f --color never'

export PATH=$HOME/scripts:$PATH

# https://wiki.archlinux.org/title/ruby 
export GEM_HOME="$(ruby -e 'puts Gem.user_dir')"
export PATH="$PATH:$GEM_HOME/bin"

# Keyboard options
#export INPUT_METHOD=fcitx
#export QT_IM_MODULE=fcitx
#export GTK_IM_MODULE=fcitx
#export XMODIFIERS=@im=fcitx
#export XIM_SERVERS=fcitx

# ZSH shell options
setopt correct                                                  # Auto correct mistakes
setopt extendedglob                                             # Extended globbing. Allows using regular expressions with *
setopt nocaseglob                                               # Case insensitive globbing
setopt rcexpandparam                                            # Array expension with parameters
setopt nocheckjobs                                              # Don't warn about running processes when exiting
setopt numericglobsort                                          # Sort filenames numerically when it makes sense
setopt nobeep                                                   # No beep
setopt appendhistory                                            # Immediately append history instead of overwriting
setopt histignorealldups                                        # If a new command is a duplicate, remove the older one
setopt autocd                                                   # if only directory path is entered, cd there.
setopt inc_append_history                                       # save commands are added to the history immediately, otherwise only when shell exits.
setopt histignorespace                                          # Don't save commands that start with space


## Custom functions

function countdown(){
    date1=$((`date +%s` + $1))
    while [ "$date1" -ge `date +%s` ]; do 
        echo -ne "$(date -u --date @$(($date1 - `date +%s`)) +%H:%M:%S)\r"
        sleep 0.1
    done
}

function stopwatch(){
    date1=`date +%s`
    while true; do
        echo -ne "$(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)\r"
        sleep 0.1
    done
}

# ex - archive extractor
# usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# print terminal colors
printcolours() {
	echo -e "\\e[0mCOLOUR_NC (No colour)"
	echo -e "\\e[1;37mCOLOUR_WHITE\\t\\e[0;30mCOLOUR_BLACK"
	echo -e "\\e[0;34mCOLOUR_BLUE\\t\\e[1;34mCOLOUR_LIGHT_BLUE"
	echo -e "\\e[0;32mCOLOUR_GREEN\\t\\e[1;32mCOLOUR_LIGHT_GREEN"
	echo -e "\\e[0;36mCOLOUR_CYAN\\t\\e[1;36mCOLOUR_LIGHT_CYAN"
	echo -e "\\e[0;31mCOLOUR_RED\\t\\e[1;31mCOLOUR_LIGHT_RED"
	echo -e "\\e[0;35mCOLOUR_PURPLE\\t\\e[1;35mCOLOUR_LIGHT_PURPLE"
	echo -e "\\e[0;33mCOLOUR_YELLOW\\t\\e[1;33mCOLOUR_LIGHT_YELLOW"
	echo -e "\\e[1;30mCOLOUR_GRAY\\t\\e[0;37mCOLOUR_LIGHT_GRAY"
}

colours() {
	local fgc bgc vals seq0

	printf "Color escapes are %s\n" '\e[${value};...;${value}m'
	printf "Values 30..37 are \e[33mforeground colors\e[m\n"
	printf "Values 40..47 are \e[43mbackground colors\e[m\n"
	printf "Value  1 gives a  \e[1mbold-faced look\e[m\n\n"

	# foreground colors
	for fgc in {30..37}; do
		# background colors
		for bgc in {40..47}; do
			fgc=${fgc#37} # white
			bgc=${bgc#40} # black

			vals="${fgc:+$fgc;}${bgc}"
			vals=${vals%%;}

			seq0="${vals:+\e[${vals}m}"
			printf "  %-9s" "${seq0:-(default)}"
			printf " ${seq0}TEXT\e[m"
			printf " \e[${vals:+${vals+$vals;}}1mBOLD\e[m"
		done
		echo; echo
	done
}
