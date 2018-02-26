#!/bin/bash
# this is a test project
currentPath=$(pwd)
currentItem=$1
itemPath=$currentPathD/$currentItem
trashPath="$HOME/.Trash_Saferm"
flashRed="\033[5;1;47;31m"
red="\033[31;40m"
none="\033[0m"
#FUNCTIONS
# INITIALIZE VARIABLES
OPT=-
NO_ARGS=0
FLAG_R=""
FLAG_F=""
FLAG_I=""
FLAG_V=""

function recursiveProcess() {
  echo " "
  read -p "Do you want to examine files in directory $1? " response
 if [[ $response == Y* ]] || [[ $response == y* ]]
 then
    interateDir $1
 else
     echo -e "Request to examine $flashRed"$1" $none"declined" "
 fi
}
function errorNoSuch() {

   echo "rm: cannot remove $* : no such file or directory"
}
moveFile(){
  mv "$1" $trashPath
}
question(){
  echo -e $none"Do you wan to remove"  $flashRed"$1?"$none
}
moveItem(){
      #first get user response to remove file

          read -p "$(question $1) " response
          if [[ $response == Y* ]] || [[ $response == y* ]] &&  [ "$FLAG_V" = "v" ]
          then
              #remove file
                  mv "$1" $trashPath
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
      moveFile $currentdir
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
                     *) mv $@ $TRASH 2>/dev/null
                      break

esac
done

}
# GETOPTS

while getopts :rRdfvi o
do    case $o in
           r|R)FLAG_R=""
             ;;
             d) FLAG_F=f
             ;;
             v) FLAG_V=v
             ;;
             i) FLAG_I=i
             ;;
             f) FLAG_I=i
             ;;
             *) errorInvalidOpt
      esac
done
shift `expr $OPTIND - 1`
currentItem=$1
# FOR FILES
if [[ -f "$currentItem" ]]; then
      moveItem $currentItem
#FOR DIRECTORIES
  elif [[ -w "$currentItem" ]];then
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
