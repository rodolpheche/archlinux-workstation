#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

for file in ~/.bash_profile.d/*.bash_profile
do
  source $file
done

if [ -z "${DISPLAY}" ] && [ "$(tty)" = "/dev/tty1" ]; then
  exec startx
fi
