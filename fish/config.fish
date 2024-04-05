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

function fish_prompt
  ~/.config/fish/prompt.py $status --shell bare ^/dev/null
end

function fish_right_prompt
  ~/.config/fish/rprompt.py $status --shell bare ^/dev/null
end





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
