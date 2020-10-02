# Brian Kummer

# All aliases are in this file
if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# Put my scripts in $HOME/bin
export PATH="$HOME/bin:$PATH"

#------------------------------------------------------------------------------
# In bash history
#   - Do not include duplicates. If I execute the same command 5 times, only 
#     include it in the history once.
#   - Also ignore commands starting with a space. I use this for unsafe 
#     commands so I don't accidentally run them in the future. 
#------------------------------------------------------------------------------
export HISTCONTROL=ignoreboth

#------------------------------------------------------------------------------
# Change prompt and window title to include Git branch
#------------------------------------------------------------------------------
export PROMPT_COMMAND=set_title_and_prompt

# Start SSH agent 
#env=~/.ssh/agent.env
#agent_load_env () { test -f "$env" && . "$env" >| /dev/null ; }
#agent_start () {
#    (umask 077; ssh-agent >| "$env")
#    . "$env" >| /dev/null ; }
#agent_load_env
# agent_run_state: 0=agent running w/key; 1=agent w/o key; 2=agent not running
#agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)
#if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
#    agent_start
#    ssh-add
#elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
#    ssh-add
#fi
#unset env

ssh-add ~/.ssh/id_rsa_teletracking_bitbucket


set_title_and_prompt() {
#----------------------------------------------------------------------------#
# Bash text color specification:  \e[<STYLE>;<COLOR>m
#    Notes: \e = \033 (oct) = \x1b (hex) = 27 (dec) = "Escape"
#           It is generally recommended to wrap color commands in \[ and \]
#   Styles: 0=normal, 1=bold, 2=dimmed, 4=underlined, 7=highlighted
#   Colors: 31=red, 32=green, 33=yellow, 34=blue, 35=purple, 36=cyan, 37=white
#----------------------------------------------------------------------------#
	COLOR_CLEAR="\[\e[0;0m\]"
	COLOR_BLACK="\[\e[0;30m\]"
	COLOR_RED="\[\e[0;31m\]"
	COLOR_GREEN="\[\e[0;32m\]"
	COLOR_YELLOW="\[\e[0;33m\]"
	COLOR_BLUE="\[\e[0;34m\]"
	COLOR_MAGENTA="\[\e[0;35m\]"
	COLOR_CYAN="\[\e[0;36m\]"
	COLOR_WHITE="\[\e[0;37m\]"

	branch="$(git rev-parse --abbrev-ref HEAD 2>&1 | grep -v 'not a git repository')"
	
    title="$PWD"
	cmd_prompt="$COLOR_BLUE\W"
	if [ "$branch" ]; then
 	  title="$title — $branch"
	  cmd_prompt="$cmd_prompt $COLOR_CYAN($branch)"
	fi
	cmd_prompt="$cmd_prompt$COLOR_BLACK$ "

	PS1="\[\e]0;$title\007\]\n$cmd_prompt"
}