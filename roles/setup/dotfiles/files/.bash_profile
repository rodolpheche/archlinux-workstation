#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

for file in ~/.bash_profile.d/*.bash_profile
do
  source $file
done >/dev/null 2>&1

if [ -z "${DISPLAY}" ] && [ "$(tty)" = "/dev/tty1" ]; then
  exec startx
fi
