# OhMyZsh configuation
export ZSH="/Users/lukeabel/.oh-my-zsh"
export DOCKER_BUILDKIT=1

# ZSH_THEME="clean" # has timestamp
# ZSH_THEME="blinks" # has topbar
ZSH_THEME="blinks-time"
HIST_STAMPS="dd.mm.yyyy"
# HYPHEN_INSENSITIVE="true"
COMPLETION_WAITING_DOTS="true"
# DISABLE_UNTRACKED_FILES_DIRTY="true" # speeds up large repos

# add plugins to ~/.oh-my-zsh/custom/plugins/
plugins=(git)
source $ZSH/oh-my-zsh.sh

# User configuration
unsetopt nomatch

## Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='vim'
fi

## Autocomplete
autoload -Uz compinit
compinit
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate

## Paths
export USER_BIN=~/bin

export PATH=${USER_BIN}:$PATH
export PATH="/usr/local/opt/libxml2/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/opt/libiconv/bin:$PATH"
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

export LDFLAGS="-L/usr/local/opt/zlib/lib:$LDFLAGS"
export LDFLAGS="-L/usr/local/opt/libiconv/lib:$LDFLAGS"
export LDFLAGS="$LDFLAGS:-L$(brew --prefix)/opt/libffi/lib"

export CPPFLAGS="-I/usr/local/opt/libiconv/include"

export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$(brew --prefix)/opt/libffi/lib/pkgconfig"

### AWS stuff
export AWS_SESSION_SOURCE_PROFILE=default
export AWS_SESSION_MFA=
export AWS_SESSION_ROLE=
export AWS_SESSION_CI_STANDARD_PROFILES=true

export AUTOTOMY_ROOT=~/repos/autotomy
export RIPGREP_CONFIG_PATH=~/.ripgreprc


## Aliases
# alias glog='git log --graph --oneline --decorate'
alias be='bundle exec'
alias rake='noglob rake' # required for certain strap tasks
alias inklinks='mdcat ~/repos/gists/inklinks/inklinks.md'
alias inknotes='mdcat ~/repos/gists/inknotes/inknotes.md'
alias railsnotes='mdcat ~/repos/gists/railsnotes/railsnotes.md'
alias linecount='tee >(wc -l | xargs echo)' # for piping ripgrep
alias login_aws='~/repos/aws_login/build/darwin-amd64/aws_login' # until it's in homebrew

## Functions
function rtest () {
  if ! [[ -z "$2" ]]; then
    ruby -I test $1 -n "/$2/"
  else
    ruby -I test $1
  fi
}

function runtest () {
  if ! [[ -z "$2" ]]; then
    bin/run ruby -I test $1 -n "/$2/"
  else
    bin/run ruby -I test $1
  fi
}

function servers () {
  cd $AUTOTOMY_ROOT && git pull
  bundle exec cap apps:$1:$2 list:servers
  cd -
}

function deploy () {
  cd $AUTOTOMY_ROOT && git pull
  bundle exec cap apps:$1:$2 deploy
  cd -
}

function tail_log () {
  cd $AUTOTOMY_ROOT && git pull
  bundle exec cap apps:$1:$2 tail:app_log
  cd -
}

function stageon {
  PROJECT=$(basename $PWD)
  # groups is www-groups in autotomy
  if [ "$PROJECT" == "groups" ]; then
    PROJECT="www-$PROJECT"
  fi
  BRANCH=$(git rev-parse --abbrev-ref HEAD)
  HOSTS=$1.staging.customink.com BRANCH=$BRANCH deploy $PROJECT staging
}

# find filenames that look like arg
function rgg() {
  rg --iglob "*$1*" -g '!/Library/' --files
}

# match literal string for arg
function rgl() {
  rg -F $1 $2
}

# match a string in files AND filenames
function rga() {
  ( rg $1; rgg $1 )
}

# find and replace. leave second arg blank for find-and-remove.
# supports filenames with whitespace.
function rgr() {
  rg $1 --files-with-matches -0 | xargs -0 sed -i '' "s/$1/$2/g"
}

function shorten() {
  if ! [[ -z "$2" ]]; then
    curl -i https://git.io -F "url=$1" -F "code=$2"
  else
    curl -i https://git.io -F "url=$1"
  fi
}

## Last Call
eval "$(rbenv init -)"
eval "$(pyenv init -)"
eval "$(nodenv init -)"
# This will set the LANG variable for your environment
export LANG=en_US.UTF-8
