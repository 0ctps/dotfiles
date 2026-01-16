#                           ___
#             ___======____=---=)
#           /T            \_--===)
#           L \ (@)   \~    \_-==)
#            \      / )J~~    \-=)
#             \\___/  )JJ~~    \)
#              \_____/JJJ~~      \
#              / \  , \J~~~~      \
#             (-\)\=|  \~~~        L__
#             (\\)  ( -\)_            ==__
#              \V    \-\) ===_____  J\   \\
#                     \V)     \_) \   JJ J\)
#                                 /J JT\JJJJ)
#                                 (JJJ| \UUU)
#                                  (UU)
#               __        __ _    _
#               \ \      / _(_)__| |_
#                > >    |  _| (_-< ' \
#               /_/     |_| |_/__/_||_|     ___
#                                          |___|





# * »   INIT
# -------------------------------------------                            /
# ----------------------------------------------------------------------/

# * cf. sgur gist =[ https://gist.github.com/sgur/1d96885a1cf34fc2bb86 ]
switch (uname)
case 'MSYS*'
  if status --is-login
    set PATH /usr/local/bin /usr/bin /bin $PATH
    set MANPATH /usr/local/man /usr/share/fish/man /usr/share/man /usr/man /share/man $MANPATH
    set -gx INFOPATH /usr/local/info /usr/share/info /usr/info /share/info $INFOPATH
    if test -n $MSYSTEM
      switch $MSYSTEM
        case MINGW32
          set MINGW_MOUNT_POINT /mingw32
          set -gx PATH $MINGW_MOUNT_POINT/bin $MSYS2_PATH $PATH
          set -gx PKG_CONFIG_PATH $MINGW_MOUNT_POINT/lib/pkgconfig $MINGW_MOUNT_POINT/share/pkgconfig
          set ACLOCAL_PATH $MINGW_MOUNT_POINT/share/aclocal /usr/share/aclocal
          set -gx MANPATH $MINGW_MOUNT_POINT/share/man $MANPATH
        case MINGW64
          set MINGW_MOUNT_POINT /mingw64
          set -gx PATH $MINGW_MOUNT_POINT/bin $MSYS2_PATH $PATH
          set -gx PKG_CONFIG_PATH $MINGW_MOUNT_POINT/lib/pkgconfig $MINGW_MOUNT_POINT/share/pkgconfig
          set ACLOCAL_PATH $MINGW_MOUNT_POINT/share/aclocal /usr/share/aclocal
          set -gx MANPATH $MINGW_MOUNT_POINT/share/man $MANPATH
        case MSYS
          set -gx PATH $MSYS2_PATH /opt/bin:$PATH
          set -gx PKG_CONFIG_PATH /usr/lib/pkgconfig /usr/share/pkgconfig /lib/pkgconfig
          set -gx MANPATH $MANPATH
        case '*'
          set -gx PATH $MSYS2_PATH $PATH
          set -gx MANPATH $MANPATH
      end
    end

    set -gx SYSCONFDIR /etc

    set ORIGINAL_TMP $TMP
    set ORIGINAL_TEMP $TEMP
    set -e TMP
    set -e TEMP
    set -gx tmp (cygpath -w $ORIGINAL_TMP 2> /dev/null)
    set -gx temp (cygpath -w $ORIGINAL_TEMP 2> /dev/null)
    set -gx TMP /tmp
    set -gx TEMP /tmp

    set p "/proc/registry/HKEY_CURRENT_USER/Software/Microsoft/Windows NT/CurrentVersion/Windows/Device"
    if test -e $p
      read PRINTER < $p
      set -gx PRINTER (echo $PRINTER | sed -e 's/,.*$//g')
    end
    set -e p

    if test -n $ACLOCAL_PATH
      set -gx ACLOCAL_PATH $ACLOCAL_PATH
    end

    set -gx LC_COLLATE C
    for postinst in /etc/post-install/*.post
      if test -e $postinst
        sh -c $postinst
      end
    end
  end
end

# ]

set -U EDITOR vim
set fish_vi_mode
set fish_greeting ""

# * »   PROMPT
# -------------------------------------------                            /
# ----------------------------------------------------------------------/
# [

# =============================================================================
# Zshrc-Style Pure Fish Prompt (Final)
# =============================================================================

# Colors (HEX)
set -g C_FG_DEFAULT bcbcbc  # DARKWHITE
set -g C_FG_ROOT    d7005f  # RED
set -g C_FG_USER    0087af  # BLUE
set -g C_FG_HOST    00ff5f  # GREEN
set -g C_FG_PATH    bcbcbc  # DARKWHITE
set -g C_FG_TIME    bcbcbc

# Git Colors
set -g C_GIT_CLEAN     00ff5f # GREEN
set -g C_GIT_DIRTY     d7005f # RED
set -g C_GIT_STAGED    ffff00 # YELLOW
set -g C_GIT_UNPUSHED  d75fff # PURPLE

# Symbols
set -g SYM_SEPARATOR " | "
set -g SYM_ARROW     "⟩"

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

function _get_formatted_path
    set -l current_dir $PWD
    set -l home_dir $HOME

    if test "$current_dir" = "$home_dir"
        echo " ~"
        return
    end

    set current_dir (string replace -r "^$home_dir" " ~" $current_dir)

    set -l parts (string split "/" $current_dir)
    set parts (string match -v "" -- $parts)

    if test (count $parts) -eq 0
        echo " /"
        return
    end

    set -l count (count $parts)
    if test $count -gt 5
        set -l head $parts[1..2]
        set -l tail $parts[-3..-1]
        set parts $head "..." $tail
    end

    string join "$SYM_SEPARATOR" $parts
end

function _git_info
    if not command git rev-parse --is-inside-work-tree >/dev/null 2>&1
        return
    end

    set -l branch (command git rev-parse --abbrev-ref HEAD 2>/dev/null)
    set -l color $C_GIT_CLEAN

    set -l indicator " "
    set -l has_change 0

    set -l upstream (command git rev-parse --symbolic-full-name --abbrev-ref @{u} 2>/dev/null)
    if test -n "$upstream"
        set -l unpushed (command git rev-list "$upstream"..HEAD --count 2>/dev/null)
        if test "$unpushed" -gt 0
            set color $C_GIT_UNPUSHED
            set indicator "$indicator^"
            set has_change 1
        end
    end

    if not command git diff --cached --no-ext-diff --quiet --exit-code 2>/dev/null
        set color $C_GIT_STAGED
        set indicator "$indicator~"
        set has_change 1
    end

    if not command git diff --no-ext-diff --quiet --exit-code 2>/dev/null
        set color $C_GIT_DIRTY
        set indicator "$indicator+"
        set has_change 1
    else
        set -l untracked (command git ls-files --others --exclude-standard 2>/dev/null)
        if test -n "$untracked"
            set color $C_GIT_DIRTY
            set indicator "$indicator+"
            set has_change 1
        end
    end

    if test $has_change -eq 0
        set indicator ""
        set color $C_GIT_CLEAN
    end

    set_color $C_FG_DEFAULT
    echo -n "$SYM_SEPARATOR"
    set_color $color
    echo -n "$branch$indicator"
    set_color normal
end

function _get_ip_address
    set -l ip_addr ""
    if type -q ip
        set -l route_info (ip route get 8.8.8.8 2>/dev/null)
        if test -n "$route_info"
            set ip_addr (echo $route_info | string match -rg 'src\s+([^\s]+)')
        end
    else if type -q route
        set -l iface (route -n get 8.8.8.8 2>/dev/null | string match -rg 'interface:\s+([^\s]+)')
        if test -n "$iface"
            if type -q ipconfig
                set ip_addr (ipconfig getifaddr "$iface")
            else if type -q ifconfig
                set ip_addr (ifconfig "$iface" 2>/dev/null | string match -rg 'inet\s+([0-9.]+)')
            end
        end
    end
    echo $ip_addr | string trim
end

# -----------------------------------------------------------------------------
# Main Prompt
# -----------------------------------------------------------------------------

function fish_prompt
    set -l last_status $status

    # Path
    set_color $C_FG_PATH
    echo -n (_get_formatted_path)

    # Git Info
    _git_info

    # Exit Status Arrow
    set_color normal
    echo -n " "
    if test $last_status -eq 0
        set_color 0087af # BLUE
    else
        set_color d7005f # RED
    end
    echo -n "$SYM_ARROW "
    set_color normal
end

function fish_right_prompt
    set -l sep_color $C_FG_DEFAULT

    # User
    if test "$USER" = "root"
        set_color $C_FG_ROOT
    else
        set_color $C_FG_USER
    end
    echo -n "$USER"

    # Separator
    set_color $sep_color
    echo -n "$SYM_SEPARATOR"

    # Host
    set_color $C_FG_HOST
    echo -n (prompt_hostname)

    # Separator
    set_color $sep_color
    echo -n "$SYM_SEPARATOR"

    # IP Address
    set -l ip (_get_ip_address)
    if test -n "$ip"
        set_color $C_FG_DEFAULT
        echo -n "$ip"
        set_color $sep_color
        echo -n "$SYM_SEPARATOR"
    end

    # Date
    set_color $C_FG_TIME
    echo -n (date +'%a %d')

    set_color $sep_color
    echo -n "$SYM_SEPARATOR"

    # Time
    set_color $C_FG_TIME
    echo -n (date +'%H:%M:%S')
    set_color normal
end

# ]





# * »   GENERAL
# -------------------------------------------                            /
# ----------------------------------------------------------------------/
# [

set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8

# * »»  path -------------------------------------------/
# [[

# Go
if type -q go
    if test -e $HOME/.go
        set -gx GOPATH $HOME/.go
        set -gx PATH $GOPATH/bin $PATH
        set -gx GO15VENDOREXPERIMENT 1
    end
end

# Cargo (Rust)
if test -e $HOME/.cargo/bin
    set -gx PATH $HOME/.cargo/bin $PATH
end

# Scripts
if test -e $HOME/.scripts.d
    set -gx PATH $HOME/.scripts.d $PATH
end

# Local bin
if test -e $HOME/.bin/bin
    set -gx PATH $HOME/.bin/bin $PATH
end

if test -e $HOME/.bin
    set -gx PATH $HOME/.bin $PATH
end

if test -e $HOME/bin
    set -gx PATH $HOME/bin $PATH
end

if test -e $HOME/usr/bin
    set -gx PATH $HOME/usr/bin $PATH
end

# ]]
# * «« -------------------------------------------------/

# ]





# * »   KEY
# -------------------------------------------                            /
# ----------------------------------------------------------------------/
# [

# vi mode escape with jj
bind -M insert jj "if commandline -P; commandline -f cancel; else; set fish_bind_mode default; commandline -f backward-char repaint-mode; end"

# ]



# * »   ALIAS
# -------------------------------------------                            /
# ----------------------------------------------------------------------/
# [

alias v='vim'
alias diff='diff -u'
alias grep='grep --color'
alias ping='ping -n'

# ls
switch (uname)
case Darwin
    alias ls='ls -G -F -L'
case '*'
    alias ls='ls -F --color=auto --group-directories-first'
end

# docker
alias d='docker'
alias dc='docker compose'
alias dcupgrade='docker compose pull && docker compose down && docker compose up -d && yes | docker system prune -a'

# tmux
if type -q tmux
    alias tl='tmux ls'
    alias tk='tmux kill-session -t'
    alias ta='tmux a'
    alias tat='tmux a -t'
end

# pygmentize (ccat)
if type -q pygmentize
    alias ccat='pygmentize -O style=monokai -f console256 -g'
end

# colordiff
if type -q colordiff
    alias cdiff='colordiff -u'
end

# grc (colorize)
if type -q grc
    alias mount='grc mount'
    alias df='grc df'
    alias ldap='grc ldap'
    alias dig='grc dig'
    alias ifconfig='grc ifconfig'
    alias netstat='grc netstat'
    # alias ping='grc ping'  # conflicts with ping -n
    alias ip='grc ip'
    alias traceroute='grc traceroute'
    alias ps='grc ps'
    alias gcc='grc gcc'
    alias g++='grc g++'
end

# ]





# * »   LOOK
# -------------------------------------------                            /
# ----------------------------------------------------------------------/
# [

# LS colors
set -gx LSCOLORS gxfxcxdxbxegedabagacad
set -gx LS_COLORS 'no=00;38;5;244:rs=0:di=00;38;5;33:ln=00;38;5;37:mh=00:pi=48;5;230;38;5;136;01:so=48;5;230;38;5;136;01:do=48;5;230;38;5;136;01:bd=48;5;230;38;5;244;01:cd=48;5;230;38;5;244;01:or=48;5;235;38;5;160:su=48;5;160;38;5;230:sg=48;5;136;38;5;230:ca=30;41:tw=48;5;64;38;5;230:ow=48;5;235;38;5;33:st=48;5;33;38;5;230:ex=00;38;5;64:'
set -gx CLICOLOR true
set -gx MANPAGER 'less -R'

# ]





# * »   OS
# -------------------------------------------                            /
# ----------------------------------------------------------------------/
# [

switch (uname)
case 'Linux*'

case 'Darwin*'

case 'CYGWIN*'

case 'MSYS*'
# [[
  function x86
    echo '(x86)'
  end
  function X86
    echo '(X86)'
  end

end

# ]



# * »   FUNCTION
# -------------------------------------------                            /
# ----------------------------------------------------------------------/
# [

# * »»  fzf functions ----------------------------------/
# [[

if type -q fzf
    # fe - edit file with fzf
    function fe
        set -l file (fzf --query="$argv[1]" --select-1 --exit-0)
        if test -n "$file"
            $EDITOR $file
        end
    end

    # fcd - cd to directory with fzf (renamed to avoid conflict with fd command)
    function fcd
        set -l dir (find $argv[1] -path '*/\.*' -prune -o -type d -print 2>/dev/null | fzf +m)
        if test -n "$dir"
            cd "$dir"
        end
    end

    # fh - search history with fzf
    function fh
        set -l cmd (history | fzf +s)
        if test -n "$cmd"
            commandline -r $cmd
            commandline -f execute
        end
    end

    # fkill - kill process with fzf
    function fkill
        set -l signal $argv[1]
        if test -z "$signal"
            set signal 9
        end
        set -l pid (ps -ef | sed 1d | fzf -m | awk '{print $2}')
        if test -n "$pid"
            echo $pid | xargs kill -$signal
        end
    end
end

# ]]
# * «« -------------------------------------------------/


# * »»  extract ----------------------------------------/
# [[

function extract
    switch $argv[1]
        case '*.tar.gz' '*.tgz'
            tar xzvf $argv[1]
        case '*.tar.xz'
            tar Jxvf $argv[1]
        case '*.zip'
            unzip $argv[1]
        case '*.lzh'
            lha e $argv[1]
        case '*.tar.bz2' '*.tbz'
            tar xjvf $argv[1]
        case '*.tar.Z'
            tar zxvf $argv[1]
        case '*.gz'
            gzip -d $argv[1]
        case '*.bz2'
            bzip2 -dc $argv[1]
        case '*.Z'
            uncompress $argv[1]
        case '*.tar'
            tar xvf $argv[1]
        case '*.arj'
            unarj $argv[1]
        case '*.rar'
            unrar x $argv[1]
        case '*'
            echo "extract: unknown archive type: $argv[1]"
    end
end

# ]]
# * «« -------------------------------------------------/


# * »»  cd with ls -------------------------------------/
# [[

function cd
    builtin cd $argv
    and ls
end

# ]]
# * «« -------------------------------------------------/


# * »»  man (color) ------------------------------------/
# [[

function man
    set -lx LESS_TERMCAP_mb (printf "\e[1;31m")
    set -lx LESS_TERMCAP_md (printf "\e[1;31m")
    set -lx LESS_TERMCAP_me (printf "\e[0m")
    set -lx LESS_TERMCAP_se (printf "\e[0m")
    set -lx LESS_TERMCAP_so (printf "\e[1;44;33m")
    set -lx LESS_TERMCAP_ue (printf "\e[0m")
    set -lx LESS_TERMCAP_us (printf "\e[1;32m")
    command man $argv
end

# ]]
# * «« -------------------------------------------------/


# * »»  sshfs functions --------------------------------/
# [[

# sshmount - mount remote directory via sshfs
function sshmount
    set -l hostname $argv[1]
    set -l username $argv[2]
    set -l server_type $argv[3]
    set -l mount_dir $argv[4]
    set -l local_dir $argv[5]

    if test -z "$mount_dir" -o -z "$local_dir"
        set mount_dir /home/$username
        set local_dir ~/.mnt/$hostname
    end

    if test "$server_type" = "local"
        set destination "$hostname.local"
    else
        set destination $hostname
    end

    if test -d $local_dir
        set -l mntchk (df | grep -c $local_dir)
        if test $mntchk -eq 0
            if ping -c 1 $destination >/dev/null 2>&1; and type -q sshfs
                sshfs -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $username@$destination:$mount_dir $local_dir
            end
        end
    end
end

# sshumount - unmount sshfs mount
function sshumount
    set -l hostname $argv[1]
    set -l username $argv[2]
    set -l server_type $argv[3]
    set -l local_dir $argv[4]

    if test -z "$local_dir"
        set local_dir ~/.mnt/$hostname
    end

    if test "$server_type" = "local"
        set destination "$hostname.local"
    else
        set destination $hostname
    end

    if test -d $local_dir
        set -l mntchk (df | grep -c $local_dir)
        if test $mntchk -gt 0
            if ping -c 1 $destination >/dev/null 2>&1
                umount $local_dir
            end
        end
    end
end

# ]]
# * «« -------------------------------------------------/


# * »»  weather ----------------------------------------/
# [[

function weather
    if type -q curl
        curl wttr.in/$argv[1]
    end
end

# ]]
# * «« -------------------------------------------------/

# ]



# * »   STARTUP
# -------------------------------------------                            /
# ----------------------------------------------------------------------/
# [

# tmux auto-start on Linux
switch (uname)
case Linux
    if test -e $HOME/.tmux.conf; and type -q tmux
        if test -z "$TMUX"; and not status is-login
            set -l ID (tmux list-sessions 2>/dev/null)
            if test -z "$ID"
                tmux new-session
            else if type -q fzf
                set -l create_new "Create New Session"
                set -l choice (printf "%s\n%s:" "$ID" "$create_new" | fzf | cut -d: -f1)
                if test "$choice" = "$create_new"
                    tmux new-session
                else if test -n "$choice"
                    tmux attach-session -t "$choice"
                end
            end
        end
    end
end

# ]
