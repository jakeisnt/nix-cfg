alias q=exit
alias clr=clear
alias sudo='sudo '

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias -- -='cd -'

# Tools
alias ag='nocorrect noglob ag'
alias l="ls -l"
alias ll="ls -1"
alias la="ls -la"
alias ln="ln -v"                    # Verbose ln
alias wget='wget -c'                # Resume dl if possible
alias rsyncd='rsync -va --delete'   # Hard sync two directories
alias mkdir='mkdir -p'
alias gurl='curl --compressed'
zman() { PAGER="less -g -s '+/^       "$1"'" man zshall; }
take() { mkdir "$1" && cd "$1"; }
compdef take=mkdir

alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(\([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\)\|[a-fA-F0-9:]\+\)' | sed -e 's/inet6* //'"

# View HTTP traffic
alias sniff="sudo ngrep -d 'en0' -t '^(GET|POST) ' 'tcp and port 80'"
alias httpdump="sudo tcpdump -i en0 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""
# URL-encode strings
alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);"'
# Make URL REQUEST shortcuts
for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
    alias "$method"="lwp-request -m '$method'"
done

# find conflicted dropbox files
alias findc="find . -iname '*conflicted*' -type f"

# Send to sprunge.us
alias bin="curl -s -F 'sprunge=<-' http://sprunge.us | head -n 1 | tr -d '\r\n ' | pbcopy"

if is-callable 'bd'; then
    alias b="bd"
    alias bb='cd "$(git root)"'
fi
if is-callable 'fasd'; then
    j() {
        local fasd_ret="$(fasd -i -d "$@")"
        [[ -d "$fasd_ret" ]] && cd "$fasd_ret" || print "$fasd_ret"
    }
fi

# transmission-remote
if is-callable 'transmission-remote'; then
    alias bt='transmission-remote server'
    alias bt-clear='bt -t all -r'

    # pretty print torrent list on remote server
    btl() {
        local results=`transmission-remote server -l | \
            awk 'NR > 1 { s = ""; for (i = 10; i <= NF; i++) s = s $i " "; print $9 " | " s  }' | \
            sed '$d' | \
            perl -pe 's/\s\[[a-zA-Z0-9]+\]\s/ /g'`

        [ -z "$results" ] && echo "No torrents!" || echo "$results"
    }
fi

# Editors
alias emacs='emacs -nw'
is-callable 'nvim' && alias vim='nvim'
v() { vim ${@:-.}; }             # Open in vim
e() { # Open in emacs (daemon)
    if pgrep Emacs 2>&1 >/dev/null; then
        emacsclient -n ${@:-.};
    else
        /Applications/Emacs.app/Contents/MacOS/Emacs ${@:-.} &
    fi
}
ee() { # emacs in project root
    git root 2>/dev/null && e "$(git rev-parse --show-toplevel)" || e .
}
ediff() {
    e --eval "(ediff-files \"$1\" \"$2\")"
}

# Compilers, interpretors 'n builders
alias va='vagrant'
alias py='python'
alias pye='pyenv'
alias rb='ruby'
alias rbe='rbenv'
alias bu='bundle'
alias bue='bundle exec'
alias bui='bundle install -path vendor'
alias ans='ansible'
alias ansp='ansible-playbook'
alias fabg='noglob fab -f ~/.dotfiles/ansible/fabfile.py'
alias rk='noglob rake'
alias rkg='noglob rake -g'
alias m='make'
alias dk='docker'
alias exe='exercism'

# GIT
is-callable 'hub' && alias git='hub'
g() { [ $# -eq 0 ] && git status --short || git $* }
compdef _git g=git

alias gi='git init'
alias gs='git status'
alias gsu='git submodule'
alias gsq='git squash'
alias gco='git checkout'
alias gc='git commit'
alias gcm='noglob git commit -m'
alias gcma='noglob git commit --amend -m'
alias gd='git diff'
alias gp='git push'
alias gpb='git push origin'
alias gpt='git push --follow-tags'
alias gpl='git pull'
alias ga='git add'
alias gau='git add -u'
alias gb='git branch'
alias gbd='git branch -D'
alias gap='git add --patch'
alias gr='git reset HEAD'
alias gt='git tag'
alias gtd='git tag -d'
alias gt!='git tag -a'
alias gls='git ls-files'

# Tmux
if is-callable 'tmux'; then
    alias t='tmux'
    alias ta='tmux attach'

    if [ -n $TMUX ]; then
        # Detach all other clients to this session
        alias takeover='tmux detach -a'
    fi

    # Start new session or create a grouped session so I'm not simply watching
    # the same session in both windows.
    tdup() {tmux new-session -t $1}
fi

if is-mac; then
    alias ls="ls -G"

    alias c11='clang++ -std=c++11'
    alias eclimd='/Applications/eclipse/eclimd'

    # Homebrew
    alias br='brew'
    alias bru='brew update && brew upgrade --all'
    alias brc='brew cask'
    alias codekit='open -a CodeKit'
elif is-cygwin; then
    alias open='cygstart'
    alias pbcopy='tee > /dev/clipboard'
    alias pbpaste='cat /dev/clipboard'
else
    alias open='xdg-open'
    alias ls="ls --color=auto"

    if (( $+commands[xclip] )); then
        alias pbcopy='xclip -selection clipboard -in'
        alias pbpaste='xclip -selection clipboard -out'
    elif (( $+commands[xsel] )); then
        alias pbcopy='xsel --clipboard --input'
        alias pbpaste='xsel --clipboard --output'
    fi
fi
alias c='pbcopy'
alias p='pbpaste'

# By default, open cwd
o() { open ${@:-.}; }
compdef o=open