#!/bin/bash
# program to emulate the "rm" command in UNIX.
# less the endless sp

#  CREATE TRASH FOLDER

if ! [ -d "$HOME/deleted" ] ; then
     mkdir $HOME/deleted
fi

# INITIALIZE VARIABLES
OPT=-
NO_ARGS=0
FLAG_R=""
FLAG_F=""
FLAG_I=""
FLAG_V=""
TRASH=$HOME/deleted


# FUNCTIONS

function errorInvailidOpt() {

    echo "rm: invalid option - $o"
    echo "try \`rm -help\` for more information"
    exit 0
}


function errorTooFew() {

   echo "rm: too few arguments"
   echo "try \`rm --help\` for more information"
}

function errorNoSuch() {

   echo "rm: cannot remove $* : no such file or directory"
}


function writePro () {
echo -n "rm: remove write-protected file \`$*'?"
read ANSWER
    if [ "$ANSWER" = "y" ] &&  [ "$FLAG_V" = "v" ] ; then
    mv $OPTS $@ $TRASH 2>/dev/null
    echo "removing \`$*'"
    else
    mv $OPTS $@ $TRASH 2>/dev/null

fi
}

function verbose () {
mv $@ $TRASH 2>/dev/null
echo "removing \`$*'"
}
function intVerbose () {
echo -n "rm: remove $* ?"
    read ANSWER
    if [ "$ANSWER" = "y" ] ; then
    mv  $@ $TRASH 2>/dev/null
    echo "removing \`$*'"


fi
}

function int () {
echo -n "rm: remove $* ?"
    read ANSWER
    if [ "$ANSWER" = "y" ] ; then
    mv  $@ $TRASH 2>/dev/null
fi
}

function delete() {
while :
do  case $OPTS in

      v|ivf|vf|ifv|vif) verbose $@
                      break
                      ;;
     vfi|fvi|iv|vi|fiv) intVerbose $@
                      break
                      ;;
               f|fv|if) mv -f $@ $TRASH 2>/dev/null
                      break
                      ;;
                     i) int $@
                      break
                      ;;
                     r)mv $OPTS $@ $TRASH 2>/dev/null
                      break
                      ;;
                     *)mv $@ $TRASH 2>/dev/null
                      break

esac
done

}


# GETOPTS

while getopts :rRfvi o
do    case $o in
           r|R)FLAG_R=""
             ;;
             f) FLAG_F=f
             ;;
             v) FLAG_V=v
             ;;
             i) FLAG_I=i
             ;;
             *) errorInvalidOpt

      esac
done
shift `expr $OPTIND - 1`

# FLOW CONTROL

OPTS=$FLAG_R$FLAG_F$FLAG_I$FLAG_V

if [ "$#" -eq "$NO_ARGS" ] ; then
   errorTooFew $@
elif ! [ -f  "$1" ] &&  ! [ -d "$1" ]; then
   errorNoSuch $@
elif ! [ -w  "$1" ] ; then
   writePro $@
else
   delete $@
fi
