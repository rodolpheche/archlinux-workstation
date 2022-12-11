# Custom prompt shell
PS1='\[\e[01;30m\]\t $(if [ $? = 0 ]; then echo "😏"; else echo "💩"; fi) \[\e[00;37m\]\u \[\e[01;34m\]\w\n \[\e[00m\]$ '
