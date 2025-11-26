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
            set ip_addr (echo $route_info | string match -r 'src\s+([^\s]+)' | awk '{print $2}')
        end
    else if type -q route
        set -l iface (route -n get 8.8.8.8 2>/dev/null | string match -r 'interface:\s+([^\s]+)' | awk '{print $2}')
        if test -n "$iface"
            if type -q ipconfig
                set ip_addr (ipconfig getifaddr "$iface")
            else if type -q ifconfig
                set ip_addr (ifconfig "$iface" 2>/dev/null | string match -r 'inet\s+([0-9.]+)' | awk '{print $2}')
            end
        end
    end
    echo $ip_addr
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
    echo -n (date +'%Y-%m-%d')

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

# ]





# * »   KEY
# -------------------------------------------                            /
# ----------------------------------------------------------------------/
# [

# ]





# * »   LOOK
# -------------------------------------------                            /
# ----------------------------------------------------------------------/
# [

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
