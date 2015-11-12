source /usr/local/bin/virtualenvwrapper.sh
source git-functions.sh
export PATH="/usr/local/bin:/usr/local/sbin:~/bin:$PATH"

export BLACK=30  RED=31  GREEN=32  YELLOW=33  BLUE=34  MAGENTA=35  CYAN=36  WHITE=37
export __PROMPT_COL=$CYAN
export GIT_PS1_SHOWDIRTYSTATE=yes
export GIT_PS1_UNSTAGED="🐉 "
export GIT_PS1_STAGED="🐠"

__colorize () {
    echo "\[\033[${1}m\]$2\[\033[0m\]"
}

__prompt_command () {
    PS1=""
    # Python virtualenv if any
    [ -n "$VIRTUAL_ENV" ] && PS1+="($(basename $VIRTUAL_ENV))"
    # Current directory
    PS1+="$(__colorize $__PROMPT_COL "$(pwd | sed "s,$HOME,~,")")"
    # Git repository
    PS1+="$(__colorize $RED "$(__git_ps1 "(%s)")")"
    PS1+="$(__docker_compose_ps1)"
    PS1+=" "
}

__docker_compose_ps1 () {
    [ -n "$USE_DOCKER_COMPOSE_PS1" ] || return
    local dc_ps1=""
    local containers=$(docker-compose ps -q 2>/dev/null)
    [ -n "$containers" ] || return
    local counts=$(docker inspect --format "{{ .State.Status }}" $containers | sort | uniq -c)
    dc_ps1=""
    while read count state ; do
        case $state in
            running)
                symbol="🌵"  # ⚡ 🍏
                ;;
            exited)
                symbol="🍄"  # ⭕ 🔴 🍎
                ;;
            *)
                echo "Invalid state: '$state'" 1>&2
                return
                ;;
        esac
        dc_ps1+="$(printf "${symbol}%.0s " $(seq 1 $count))"
    done <<< "$counts"
    dc_ps1=" ($dc_ps1)"
    dc_ps1=$(__colorize $__CYAN "$dc_ps1")
    echo -n "$dc_ps1"
}

export PROMPT_COMMAND=__prompt_command
PS2=''

source /Users/catherine/git-completion.bash

if [ -f `brew --prefix`/etc/bash_completion ]; then
    . `brew --prefix`/etc/bash_completion
fi

# export EDITOR='subl -w'

alias denv='eval "$(docker-machine env dockervm)"'

alias docker-prune='docker rmi $(docker images -f "dangling=true" -q)'
alias docker-rm-all='docker rm -f $(docker ps -a -q)'
alias docker-clean='docker-rm-all && docker-prune'

# Return the name of the unique container for the docker-compose service
# identified by the first argument.
docker-compose-get-container() {
    local service="$1"
    local container=$(docker-compose ps "$service" | sed 1,2d | awk '{print $1}')
    local n_containers=$(echo -n "$container" | grep -c '^')
    [ "$n_containers" -ne 1 ] && die "$n_containers containers found for service: $service"
    echo "$container"
}

# E.g. docker-compose exec -it $service bash
docker-compose-exec () {
    local exec_args=""
    while [[ "$1" == -* ]] ; do exec_args+="$1" ; shift ; done
    local service="$1"
    shift
    docker exec $exec_args $(docker-compose-get-container "$service") $@
}

die () {
    echo "$@" >&2
    return 1
}

# added by Anaconda3 2.3.0 installer
export PATH="/Users/catherine/anaconda/bin:$PATH"

#Virtualenv
export WORKON_HOME=$HOME/.virtualenvs
export MSYS_HOME=/c/msys/1.0
source /usr/local/bin/virtualenvwrapper.sh
