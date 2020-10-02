# My bash shell aliases and functions
#
# Bash aliases do any command substitution at time shell is created, NOT the
# time the command is executed. Functions do command substitution when the
# function is executed. For example, if we want to do this to print current 
# date in local time and UTC on the same line:
#   alias datetime-local-utc="echo \"$(date +'%F %T %Z') = $(date -u +'%F %T %Z')\""
# will always show the datetime that the shell was opened, not the *current*
# datetime. But
#   function datetime-local-utc() {
#     echo "$(date +'%F %T %Z') = $(date -u +'%F %T %Z')"
#   }
# will show the datetime the function is executed, which is what I want.

case "$OSTYPE" in
  darwin*)
    ##########################################################################
    # For my TeleTracking Mac
    ##########################################################################
    LS_COMMAND="ls -laG"

    alias grep='grep --color=auto'
    alias egrep='egrep --color=auto'
    alias fgrep='fgrep --color=auto'

    # Alias to script for setting keyboard lights
    alias keyboard-lights="~/.hammerspoon/keyboard-lights.sh"

    # The SSH_xxx_LOGIN variables are formatted like "username@ipaddr:port"
    # and have to be converted to "username@ipaddr -pport"
    alias ssh-router="ssh ${SSH_ROUTER_LOGIN/:/ -p} -i '~/Personal/Digital Keys/router-ssh.pem'"
    alias ssh-pi-living-room="ssh ${SSH_PI_LIVING_ROOM_LOGIN/:/ -p} -i '~/Personal/Digital Keys/pi-ssh.pem'"
    alias ssh-pi-bed-room="ssh ${SSH_PI_BED_ROOM_LOGIN/:/ -p} -i '~/Personal/Digital Keys/pi-ssh.pem'"
    alias ssh-pi-living-room-NEW="ssh ${SSH_PI_LIVING_ROOM_NEW_LOGIN/:/ -p} -p1944 -i '~/Personal/Digital Keys/id_rsa_pi_v2.pem'"

    # Switch between TeleTracking and personal accounts
    #   - Since my personal SSH key has a passphrase, only add it when I switch 
    #     to my personal Git
    alias git-tele="cd ~/dev/git"
    alias git-personal="cd ~/Personal/Code/git && ssh-add ~/.ssh/id_rsa_personal"
    
    alias gdiff="git difftool"     # Use IntelliJ to diff files, which is configured in .gitconfig
    alias cd-sprint="cd ~/dev/git/microservice.readstore.transfercaselog"

    # Output current time as local and UTC on one line, such as
    #   "2020-05-14 19:01:30 EDT = 2020-05-14 23:01:30 UTC
    # This can be done by echoing the output of those commands like this
    #   echo "$(date), $(date -u)"
    function datetime-local-utc() {
      echo "$(date +'%F %T %Z') = $(date -u +'%F %T %Z')"
    }

    # Ping the non-prod ESS
    #   - Returns "000" if it times out, else returns "HTTP 1.1/xxx"
    #   - Enables things like this
    #       for i in {1..20}; do echo "$(datetime-local-utc) >>>> ESS = $(ping-np-ess)" && sleep 60; done
    #alias ping-np-ess="curl --max-time 5 --silent --include -w %{http_code} --cert ~/certificates/$EVENT_STORE_NONPROD_CERT:$EVENT_STORE_NONPROD_PASSWD --key ~/certificates/$EVENT_STORE_NONPROD_KEY --cacert ~/certificates/$EVENT_STORE_NONPROD_CACERT $EVENT_STORE_NONPROD_URL/ping | grep -Ei '(^\d\d\d$|timed out|HTTP)'"
    alias ping-np-ess-raw="curl --cert ~/certificates/$EVENT_STORE_NONPROD_CERT:$EVENT_STORE_NONPROD_PASSWD --key ~/certificates/$EVENT_STORE_NONPROD_KEY --cacert ~/certificates/$EVENT_STORE_NONPROD_CACERT $EVENT_STORE_NONPROD_URL/ping"
    alias ping-np-ess="ping-np-ess-raw --max-time 5 --silent --include -w %{http_code} | grep -Ei '(^\d\d\d$|timed out|HTTP)'"
    # I can't get this to work- I get this response:
    #   {"timestamp":"2020-09-07T01:27:23.525+0000","status":404,"error":"Not Found","message":"No message available","path":"/consume/ping"}
    #alias ping-PRODUCTION-ess-raw="curl --cert ~/certificates/$EVENT_STORE_PROD_CERT:$EVENT_STORE_PROD_PASSWD --key ~/certificates/$EVENT_STORE_PROD_KEY --cacert ~/certificates/$EVENT_STORE_PROD_CACERT $EVENT_STORE_PROD_URL/ping"
    #alias ping-PRODUCTION-ess="ping-PRODUCTION-ess-raw --max-time 5 --silent --include -w %{http_code} | grep -Ei '(^\d\d\d$|timed out|HTTP)'"
    
    # Kubernetes stuff
    alias k="kubectl"
    alias k-PRODUCTION="kubectx PrdUSIQAKS"
    alias k-np="kubectx StgUSIQAKS"
    alias k-cheat="chrome https://kubernetes.io/docs/reference/kubectl/cheatsheet/"

    # Use this to grep output of a kubernetes log looking for ESS timeouts
    alias k-grep-ess-timeout="grep -B 2 -A 3 -E \"ExecutionException.*java.util.concurrent.TimeoutException\""

    # Aliases to scripts I use
    alias k-pods-get-errors="~/bin/k-pods-get-errors.sh"
    alias k-pods-get-tc="datetime-local-utc && ~/bin/k-pods-get-tc.sh"
    alias k-pods-get-tcl="datetime-local-utc && (~/bin/k-pods-get-tc.sh | grep transfercaselog)"
    alias k-pods-get-instances="~/bin/k-pods-get-instances.sh"
    alias k-pods-get-leaders="~/bin/k-pods-get-leaders.sh"
    alias k-pods-get-tenant="~/bin/k-pods-get-tenant.sh"
    alias k-pods-backup-logs="~/bin/k-pods-backup-logs.sh"

    # Start Mongo shell and connect to a mongo instance, which enables things 
    # like this
    #   cat test-file.js | mongo-np
    #   mongo-np "db.getCollectionNames()"
    #   mongo-np "db.getCollection('xxxxxxx').count()"
    function mongo-local() {
      mongo-shell "mongodb://$MONGO_LOCAL_URL_AND_OPTIONS" $@ "$(cat /dev/stdin)"
    }
    function mongo-np() {
      mongo-shell "mongodb://$MONGO_NONPROD_USER_ID:$MONGO_NONPROD_PASSWD@$MONGO_NONPROD_URL_AND_OPTIONS" $@ "$(cat /dev/stdin)"
    }
    function mongo-PRODUCTION() {
      mongo-shell "mongodb://$MONGO_PROD_USER_ID:$MONGO_PROD_PASSWD@$MONGO_PROD_URL_AND_OPTIONS" $@ "$(cat /dev/stdin)"
    }
    function mongo-shell() {
      cleanCmd=""
      for arg in "$@"
      do
        # TODO: Fix broken interactive. Want to be able to do "mongo-PRODUCTION" and be dropped into an interactive shell

        # We have 2 or 3 arguments
        #   --clean      Signals that we want all Mongo connection info to be stripped out
        #   mongodb://*  The connection string
        #   *            The command to execute
        case "$arg" in
          --clean)   cleanCmd="| grep -vE \"^\d+-\d\d-\d\dT.* (I|W)  (NETWORK|CONNPOOL)\"";;
          mongodb*)  mongoUrlAndOptions="$arg";;
          *)         mongoCmd="$arg";;
        esac
      done
      cmd="mongo --quiet '$mongoUrlAndOptions' --eval '$mongoCmd' $cleanCmd"
      eval "$cmd"
    }

    # Common Mongo things I do
    #   mongo-tenant-rebalancing 2020-09-30T00:00:00 | mongo-np --clean
    #   mongo-instances-count | mongo-np --clean
    #   for i in {1..10000}; do echo "$(datetime-local-utc) >>>> # Instances = $(mongo-instances-count | mongo-PRODUCTION --clean)" && sleep 120; done
    # TODO
    #   - How pass in a service name into these, including mongo-tenant-rebalancing?
    alias mongo-instances-count="echo 'db.getMongo().getDB(\"transfercaselog\").getCollection(\"Instances\").count()'"
    alias mongo-instances-tenants="echo 'db.getMongo().getDB(\"transfercaselog\").getCollection(\"Instances\").aggregate({\$project:{NumTenants:{\$size:\"\$tenantIds\"}}}).pretty()'"
    function mongo-tenant-rebalancing() {
      # Replace "new Date(...)" with "new Date($1)", strip out comment lines and then newlines
      echo "$(sed "s/new Date(\".*\")/new Date(\"$1\")/g" ~/mongojs/tenant-rebalancing.js | sed '/^ *\/\//d' | tr -d '\n')"
    }

    # Alias so can use event-stream script from anywhere
    alias event-stream="/Users/briankummer/Dev/git/cloud-tools/event-stream/event-stream"

    # Not sure these shortcuts are actually helpful
    alias intellij="/Applications/IntelliJ\\ IDEA\\ CE.app/Contents/MacOS/idea &"
    alias vsc="/Applications/Visual\\ Studio\\ Code.app/Contents/MacOS/Electron"
    alias chrome="/Applications/Google\\ Chrome.app/Contents/MacOS/Google\\ Chrome"
    ;; 

  linux-gnueabihf*)
    ##########################################################################
    # For my Raspberry Pi's
    ##########################################################################
    LS_COMMAND="ls -la"
    ;;

  msys)
    ##########################################################################
    # Windows, running MinGW ("Minimalist GNU for Windows")
    ##########################################################################
    LS_COMMAND="ls -la"

    alias docker="winpty docker"
    ;;
esac



##############################################################################
# Aliases for all platforms
##############################################################################
alias gs="git status"

alias ..="cd .."
alias l="$LS_COMMAND"
alias h="history"
alias hs="history | grep"

alias dps="docker ps"
alias dc="docker-compose"
alias dcu="docker-compose up -d"
alias dcd="docker-compose down -v"
alias dcl="docker-compose logs"

# CDD: "cdd [folder_name]"" is equivalent to "cd folder_name && ls -la"
function cdd() {
  DIR="$*";
  [ $# -lt 1 ] && DIR=$HOME;  # Default to $HOME if no argument passed
  cd "${DIR}" && $LS_COMMAND
}

