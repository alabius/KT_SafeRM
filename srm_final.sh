#!/bin/bash
# program to emulate the "rm" command in UNIX.
loopArray[0]='.'
loopCount=0
dirCount=$( ls -l "$@" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' | wc -l | xargs)
dirItems=$(ls -l "$@" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' )
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
FLAG_D=""
#Create variable to hold TRASH DIRECTORY
TRASH=$HOME/deleted

#confirm if response is YES or NO
isYes(){
  [[ $response =~ ^[y*/Y*]$ ]]
}

# FUNCTIONS to process script for files
forFiles() {
    read -p "Do you want to remove $1? " response
    #if the first letter of the reply is lower or upper case Y
    if isYes;
    then
        mv  "$@" $TRASH 2>/dev/null
        echo "$1 removed"
    #If the response if another other thing other than Y or y
    else
        echo "Request declined"
    fi
}

# FUNCTIONS to process script for directory
forDirectories() {

    loopCount=$((loopCount+1))
    loopArray[$loopCount]=$@

    echo "$@ is a directory"
    read -p "Do you want to examine files in directory $@? " response

    #if the first letter of the reply is lower or upper case Y
    if isYes
    then
        #examine each file
        # presentPath=$1
        echo $dirCount
        if [[ $dirCount -gt true ]]
        then
            echo "This directory is not empty"
            for i in $dirItems; do

                #check if item is a file or directory
                ifFileOrDir "$@/$i"

                if [[ $i -eq true ]]
                then
                        forFiles "$@/$i"
                else

                  forDirectories "$@/$i"

                  # #handle caller
                  # forFiles "${loopArray[$loopCount]}"
                  # move back one folder
                  loopCount=$((loopCount-1))
                fi
            done
        else
            echo "This directory is empyt"
            #delete the directory
            forFiles $@
            # presentPath=$(dirName $@)
        fi
      else
        echo "Request denied"
    fi

}

#Function to check if the item is file or directory
function ifFileOrDir() {
  if [[ -f "$1" ]]
  then
      true
  else
      false
  fi
}

#function to handle errors when no argument is supply to the command
function errorInvailidOpt() {
  echo "rm: invalid option - $o"
  echo "try \`rm -help\` for more information"
  exit 0
}

#function to handle errors when option supplied do not match
function errorTooFew() {
  echo "rm: too few arguments"
  echo "try \`rm --help\` for more information"
}

#function to handle errors when argument supplied do not exist
function errorNoSuch() {
  echo "Error: $* is not a valid file or directory"
}

#function to handle errors when argument supplied is write protected
function writePro () {
  echo -n "$* is write protected, do you want to still remove $*? "
  read ANSWER
    if [ "$ANSWER" = "y" ] &&  [ "$FLAG_V" = "v" ] ; then
      mv $OPTS $@ $TRASH 2>/dev/null
      echo "$* removed successfully"
    else
      mv $OPTS $@ $TRASH 2>/dev/null
    fi
}

#function to handle verbose i.e v|ivf|vf|ifv|vif options
function verbose () {
  echo -n "Do you want to remove $*? "
  read ANSWER
  if [ "$ANSWER" = "y" ]; then
    mv $@ $TRASH 2>/dev/null
    echo "$* successfully removed"
  else
    echo " $* not removed"
  fi
}

#function to handle verbose i.e vfi|fvi|iv|vi|fiv options
function intVerbose () {
  echo -n "Do you want to remove $*? "
  read ANSWER
  if [ "$ANSWER" = "y" ] ; then
    mv $@ $TRASH 2>/dev/null
    echo "$* removed successfully"
  else
    echo "Oops, $@ not removed"
  fi
}

#function to handle verbose i.e -i options
function int () {
  echo -n "Do you want to remove $*? "
  read ANSWER
  if [ "$ANSWER" = "y" ]; then
    mv $@ $TRASH 2>/dev/null
    echo "$@ recobvered successfully"
  else
    echo "Oops, request denied"
  fi
}

#Function to recover file from the trash to the parent working directory
function undo () {
  echo -n "Do you want to recover $*? "
  read ANSWER
  if [ "$ANSWER" = "y" ]; then
    for file in  $@ ; do
    if [ -w "$TRASH/$file" ] ; then
        mv "$TRASH/$file" $PWD
    else
        echo "Hmm,.. I cannot find $file."
    fi
    done
  fi
}
#function to execute with supplied options -v -f -d -i or combinations
function delete() {
while :
do  case $OPTS in

      v|ivf|vf|ifv|vif) if [[ -f "$1" ]]; then
                          verbose $@
                        else
                          echo "$@ is a directory"
                        fi
                      break
                      ;;
     vfi|fvi|iv|vi|fiv) intVerbose $@
                      break
                      ;;
               f|fv|if) if [[ -f "$1" ]]; then
                          mv $OPTS $@ $TRASH 2>/dev/null
                        else
                          echo "$@ is a directory"
                        fi
                      break
                      ;;
                     i) if [[ -f "$1" ]]; then
                          int $@
                        else
                          echo "$@ is a directory"
                        fi
                      break
                      ;;
                     r|R) mv $OPTS $@ $TRASH 2>/dev/null
                      break
                      ;;
                     d) mv $OPTS $@ $TRASH 2>/dev/null
                      break
                      ;;
                     u) undo $@
                      break
                      ;;
                     *) if [[ -f "$1" ]]
                          then
                            forFiles $@
                          else
                            forDirectories $@
                     fi
                      break
esac
done

}


# GETOPTS for all options to used

while getopts :rRfvidu o
do    case $o in
             R)FLAG_R=R
             ;;
             r) FLAG_F=r
             ;;
             f) FLAG_F=f
             ;;
             v) FLAG_V=v
             ;;
             i) FLAG_I=i
             ;;
             d) FLAG_D=d
             ;;
             u) FLAG_U=u
             ;;
             *) errorInvalidOpt

      esac
done
shift `expr $OPTIND - 1`

# FLOW CONTROL for all flags

OPTS=$FLAG_R$FLAG_F$FLAG_I$FLAG_V$FLAG_D$FLAG_U

#check if there is any supplied arguments
if [ "$#" -eq "$NO_ARGS" ] ; then
   errorTooFew $@
# elif ! [ -f  "$1" ] &&  ! [ -d "$1" ]; then
#    errorNoSuch $@
# elif ! [ -w  "$1" ] ; then
#    writePro $@
else
   delete $@
fi
