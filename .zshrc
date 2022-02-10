#--- OH-MY-ZSH --------------------------------------------------------------
export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="spaceship"

ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

plugins=(
	zsh-autosuggestions
	zsh-syntax-highlighting
	direnv
	fzf
	h
	k
	git
	docker
	docker-compose
	npm
	# yarn
	pass
)

ZSH_AUTOSUGGEST_USE_ASYNC="true"

SPACESHIP_DOCKER_SHOW=false
SPACESHIP_TIME_SHOW=true
SPACESHIP_DIR_TRUNC_REPO=true
#---------------------------------------------------------------------------


#--- OPTIONS --------------------------------------------------------------
setopt BANG_HIST              # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY       # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY     # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY          # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS       # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS   # Delete old recorded entry if new entry is a duplicate.
#setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE  # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS  # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY        # Don't execute immediately upon history expansion.
#---------------------------------------------------------------------------


#--- EXPORT --------------------------------------------------------------
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export LC_COLLATE="C"
export VISUAL="vim"
export EDITOR="vim"
export TERM="xterm-256color"

export HISTSIZE=5000
export SAVEHIST=5000

#export FZF_BASE=~/.zsh/fzf
export FZF_DEFAULT_COMMAND='fd --type file --type directory --absolute-path --follow --hidden --exclude .git --exclude node_modules --color=always'
export FZF_DEFAULT_OPTS="--ansi"

export MANPAGER="sh -c 'col -bx | bat -l man -p'"

export TIPZ_TEXT='💡 '
export WEBFLO_DIR=$HOME/.webflo
export DOTFILES_DIR=$HOME/.dotfiles-git
export VOLTA_HOME="$HOME/.volta"
#---------------------------------------------------------------------------




source $ZSH/oh-my-zsh.sh




#--- ALIASES --------------------------------------------------------------
alias cd..="cd .."
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias -- -="cd -"


# alias ls='ls -l -h -v --group-directories-first --time-style=+"%Y-%m-%d %H:%M" --color=auto -F --tabsize=0 --literal --show-control-chars --color=always --human-readable'
# alias la='ls -a'

alias grep="grep --color=auto"
alias sgrep='grep -R -n -H -C 5 --exclude-dir={.git,.svn,CVS} '
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"
alias less="less -R"

alias dud='du -d 1 -h'
alias duf='du -sh *'

#alias fd='find . -type d -name'
#alias ff='find . -type f -name'
#alias fd=fdfind

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Make zsh know about hosts already accessed by SSH
zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

alias path='echo -e ${PATH//:/\\n}'

alias auto-update="sudo apt -y update && sudo apt -y full-upgrade && sudo apt -y autoremove"

alias ip-local="ip a | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'"

alias ssh-add='eval "$(ssh-agent -s)" && ssh-add'

alias lazydocker='docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock -v /home/florent/docker/lazydocker//config:/.config/jesseduffield/lazydocker lazyteam/lazydocker'

alias dive='docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive:latest'

alias dotfiles='git --git-dir=$DOTFILES_DIR --work-tree=$HOME'

alias view='bat'
alias cat='bat -p'

alias vi=vim
#alias nano=vim

alias ls='exa -la -L 3 --git --group-directories-first --ignore-glob="node_modules|.git"'
alias la=ls

alias man=cheat

alias keepalive-vdi="xdotool key --window $(comm -12 <(xdotool search --name 'FR09540462W' | sort) <(xdotool search --class 'Wfica' | sort)) --delay 300000 --repeat 288 space"
#---------------------------------------------------------------------------



if [[ -d $HOME/.zsh ]]; then
  for file in $HOME/.zsh/*.{zsh,sh}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file"
    unset file
  done
fi


#---FUNCTIONS (move to bin ?) --------------------------------------------------------------
# dotfiles with git bare repository
function dotfiles-add () {
   if [[ -n "$@" ]]; then
      dotfiles add "$@"
   else
      selection=$(fd --strip-cwd-prefix --base-directory $HOME --type file --type directory --follow --hidden --color=always --exclude .git --exclude node_modules | fzf -m --height 40% --no-mouse)
      if [[ -n "$selection" ]]; then
         selection=("${(@f)${selection}}")
         echo "-- added --"
	 for item in ${selection[@]}; dotfiles add $HOME/$item && echo $item
      else
         echo "nothing was added."
      fi
   fi
}

# Create a new directory and enter it
function mkd() {
	mkdir -p "$@" && cd "$_";
}

# Backup a file aka copy/paste with new filename
function bak() {
    cp -a "$1" "${1}_$(date --iso-8601=seconds)";
}

# Search process by name and highlight !
function psgrep() {
    ps axuf | grep -v grep | grep "$@" -i --color=auto;
}

# Search for files and page it
function search() {
    find . -iname "*$@*" | less;
}

# Search text in file content
function fif() {
    grep -rnw --exclude-dir={.git,node_modules,coverage,__snapshots__,migrations,venv,bower_components} . -e $1;
}

# Create a .tar.gz archive, using `zopfli`, `pigz` or `gzip` for compression
function targz() {
	local tmpFile="${@%/}.tar";
	tar -cvf "${tmpFile}" --exclude=".DS_Store" "${@}" || return 1;

	size=$(
		stat -f"%z" "${tmpFile}" 2> /dev/null; # macOS `stat`
		stat -c"%s" "${tmpFile}" 2> /dev/null;  # GNU `stat`
	);

	local cmd="";
	if (( size < 52428800 )) && hash zopfli 2> /dev/null; then
		# the .tar file is smaller than 50 MB and Zopfli is available; use it
		cmd="zopfli";
	else
		if hash pigz 2> /dev/null; then
			cmd="pigz";
		else
			cmd="gzip";
		fi;
	fi;

	echo "Compressing .tar ($((size / 1000)) kB) using \`${cmd}\`…";
	"${cmd}" -v "${tmpFile}" || return 1;
	[ -f "${tmpFile}" ] && rm "${tmpFile}";

	zippedSize=$(
		stat -f"%z" "${tmpFile}.gz" 2> /dev/null; # macOS `stat`
		stat -c"%s" "${tmpFile}.gz" 2> /dev/null; # GNU `stat`
	);

	echo "${tmpFile}.gz ($((zippedSize / 1000)) kB) created successfully.";
}


# Determine size of a file or total size of a directory
function fs() {
	if du -b /dev/null > /dev/null 2>&1; then
		local arg=-sbh;
	else
		local arg=-sh;
	fi
	if [[ -n "$@" ]]; then
		du $arg -- "$@";
	else
		du $arg .[^.]* ./*;
	fi;
}
#---------------------------------------------------------------------------


#--- USER CONFIGURATION --------------------------------------------------------------
path=($VOLTA_HOME/bin $HOME/bin $HOME/.local/bin $HOME/go/bin /usr/local/go/bin $HOME/.cargo/bin $path)
fpath=($HOME/.zsh/completions $fpath)

# Make zsh know about hosts already accessed by SSH
zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'
#---------------------------------------------------------------------------

