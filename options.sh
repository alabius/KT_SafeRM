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
question(){
  echo -e $none"Do you wan to remove"  $flashRed"$1?"$none
}
moveItem(){
      #first get user response to remove file

          read -p "$(question $1) " response
          if [[ $response == Y* ]] || [[ $response == y* ]] &&  [ "$FLAG_V" = "v" ]
          then
              #remove file
                  mv $@ $TRASH 2>/dev/null
                  echo -e $non"You just removed" $flashRed"$1 $none"
          #      # echo "$1 has been removed"
          else
              #file isn't remove
                  echo ""
                  echo -e $non"You just declined to remove" $flashRed"$1 $none"
          fi
   # fi
}

 backOneStep(){
  # currentdir=$(dirname $currentdir)
  dirChek=$(ls -l "$currentdir" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' | wc -l | xargs)
  read -p "Do you want to remove  $currentdir? " response
    if [[ $response == Y* || $response == y* ]] && [[ $dirChek -eq 0 || $dirChek -gt 0 ]]
    then
      # removeFile
      moveItem $currentdir
      echo ""
      echo "$currentdir successfully removed"
    else
        echo
        echo "Request to remove $currentdir declined"
    fi

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
interateDir(){

     currentdir="$1"
     totalItems=$(ls -l "$currentdir" | sort -k1,1  | awk -F " " '{print $NF}' | sed -e '$ d')

    # dirChek=$(ls -l "$1" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' | wc -l | xargs)

          for object in $totalItems
          do

              # echo "looping again"
              if [[ -f "$currentdir/$object" ]]
              then
                # echo "$object is a file"
                  moveItem $currentdir/$object
              else
                    dirChek=$(ls -l "$currentdir/$object" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' | wc -l | xargs)
										echo " "
										read -p "Do you want to examine files in directory $currentdir/$object? " response
                    if [[ $response == Y* || $response == y* ]]
                    then
                       if [[ $dirChek -gt 0 ]]
                       then
                        interateDir $currentdir/$object
                      else
                        moveItem $currentdir/$object
                      fi

                    else
                        echo "$currentdir/$object not examined"
                    fi

              fi
          done
           backOneStep $currentdir/$object

           currentdir=$(dirname $currentdir)

}
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
echo "$* removed successfully"
}
function intVerbose () {
echo -n "Do you want to remove $*? "
    read ANSWER
    if [ "$ANSWER" = "y" ] ; then
      mv  $@ $TRASH 2>/dev/null
    echo "$* removed successfully"
    else
      echo "$@ not removed"


fi
}

function int () {
echo -n "Do you want to remove $*? "
    read ANSWER
    if [ "$ANSWER" = "y" ] ; then
    mv  $@ $TRASH 2>/dev/null
fi
}
function noOptions () {
  if [[ -f "$1" ]]; then
        mv $@ $TRASH 2>/dev/null
  #FOR DIRECTORIES
elif [[ -w "$1" ]];then
            echo " "
            read -p "Do you want to examine files in directory $1? " response
           if [[ $response == Y* ]] || [[ $response == y* ]]
           then
              interateDir $1
           else
               echo -e "Request to examine $flashRed"$1" $none"declined" "
           fi
  else
    errorNoSuch $1
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
                     r) mv $OPTS $@ $TRASH 2>/dev/null
                      break
                      ;;
                     *) noOptions $@
                      break
                      ;;
                     *) mv $@ $OPTS $TRASH 2>/dev/null
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
