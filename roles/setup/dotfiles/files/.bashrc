#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Custom aliases
alias grep='grep --color'

for file in ~/.bashrc.d/*.bashrc
do
  source "$file"
done
