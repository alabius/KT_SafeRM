#!/bin/bash
# program to emulate the "rm" command in UNIX.
loopArray[0]='.'
loopCount=0
dirCount=$( ls -l "$@" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' | wc -l | xargs)
dirItems=$(ls -l "$@" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' )
currentPath=$(pwd)
currentItem=$@
itemPath=$currentPath/$currentItem
# logItemPath=$( find $PWD -name "$@" -type f -o -type d >> logItems.txt )

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

moveItem(){
      #first get user response to remove file
          read -p "remove $1? " response
          if [[ $response == Y* ]] || [[ $response == y* ]]
          then
              #remove file
                  # mv "$1" $trashPath
                  echo "You just removed $1"
          #      # echo "$1 has been removed"
          else
              #file isn't remove
                  echo " "
          fi
   # fi
}

backOneStep(){
 # currentdir=$(dirname $currentdir)
 dirContentsCheck=$(ls -l "$currentdir" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' | wc -l | xargs)
 read -p "Do you want to remove  $currentdir? " response
   if [[ $response == Y* || $response == y* ]] && [[ $dirContentsCheck -eq 0 || $dirContentsCheck -gt 0 ]]
   then
     # removeFile
     mv  "$currentdir" $HOME 2>/dev/null
     echo "$currentdir removed"
   else
      echo "$currentdir not removeFiled"
   fi

   }

  interateDir(){

      currentdir="$1"
      totalItems=$(ls -l "$currentdir" | sort -k1,1  | awk -F " " '{print $NF}' | sed -e '$ d')

     # dirContentsCheck=$(ls -l "$1" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' | wc -l | xargs)

           for i in $totalItems
           do

               # echo "looping again"
               if [[ -f "$currentdir/$i" ]]
               then
                 # echo "$i is a file"
                   moveItem $currentdir/$i
               else
                     dirContentsCheck=$(ls -l "$currentdir/$i" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' | wc -l | xargs)
  										echo " "
  										read -p "Do you want to examine files in directory $currentdir/$i? " response
                     if [[ $response == Y* || $response == y* ]]
                     then
                        if [[ $dirContentsCheck -gt 0 ]]
                        then
                         interateDir $currentdir/$i
                       else
                         moveItem $currentdir/$i
                       fi

                     else
                         echo "$currentdir/$i not examined"
                     fi

               fi
           done
            backOneStep $currentdir/$i

            currentdir=$(dirname $currentdir)

  }

#confirm if response is YES or NO
isYes(){
  [[ $response =~ ^[y*/Y*]$ ]]
}

# FUNCTIONS to process script for files
forFiles() {
    read -p "remove $1? " response
    #if the first letter of the reply is lower or upper case Y
    if isYes;
    then
        mv  "$@" $TRASH 2>/dev/null
        $logItemPath
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
    if [[ $response =~ ^[y*/Y*]$ ]]
    then
        #examine each file
        if [[ $dirCount -gt true ]]
          # echo $dirCount
        then
            echo "This directory is not empty"
            for i in $dirItems; do
                #check if item is a file or directory
                if [[ -f "$@" ]]
                then
                  forFiles "$@/$i"
                else
                  # if [[ $@ -eq false ]]
                  forDirectories "$@/$i"
                  # #handle caller
                  forFiles "${loopArray[$loopCount]}"
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

#Function for options i
function vOption(){
  if [[ -f "$1" ]]; then
    verbose $@
  else
    echo "$@ is a directory"
  fi
}

#Function for options i
function iOption(){
  if [[ -f "$1" ]]; then
     int $@
   else
     echo "$@ is a directory"
   fi
}
#Function for options f
function fiOption(){
  if [[ -f "$1" ]]; then
    mv $OPTS $@ $TRASH 2>/dev/null
   else
     echo "$@ is a directory"
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
  echo "srm: invalid option - $o"
  echo "try \`rm -help\` for more information"
  exit 0
}

#function to handle errors when option supplied do not match
function errorTooFew() {
  echo "srm: too few arguments"
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
  echo -n "remove $*? "
  read ANSWER
  if [ "$ANSWER" = "y" ]; then
    mv itemPath $TRASH 2>/dev/null
    echo "$*"
  else
    echo ""
  fi
}

#function to handle verbose i.e vfi|fvi|iv|vi|fiv options
function intVerbose () {
  echo -n "Do you want to remove $*? "
  read ANSWER
  if [ "$ANSWER" = "y" ] ; then
    mv $@ $TRASH 2>/dev/null
    echo "$* removed"
  else
    echo ""
  fi
}

#function to handle verbose i.e -i options
function int () {
  echo -n "remove $*? "
  read ANSWER
  if [ "$ANSWER" = "y" ]; then
    mv $@ $TRASH 2>/dev/null
    echo ""
  else
    echo " "
  fi
}

#Full delete no-options
function delFile(){
  if [[ -f "$1" ]]
     then
       forFiles $@
     else
        echo ""
        read -p "examine files in directory $1? " response
        if [[ $response == Y* ]] || [[ $response == y* ]]
        then
          interateDir $1
        else
          echo " "
        fi
  fi
}

#Function to recover file from the trash to the parent working directory
function undo () {
  echo -n "recover $*? "
  read ANSWER
  if [ "$ANSWER" = "y" ]; then
    for file in  $@ ; do
    if [ -w "$TRASH/$file" ] ; then
        mv "$TRASH/$file" $currentPath/
    else
        echo ""
    fi
    done
  fi
}

#function to execute with supplied options -v -f -d -i or combinations
function delete() {
  while :
    do  case $OPTS in

          v|ivf|vf|ifv|vif) vOption $@
                          break
                          ;;
         vfi|fvi|iv|vi|fiv) intVerbose $@
                          break
                          ;;
                   f|fv|if) fiOption $@
                          break
                          ;;
                         i) iOption $@
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
                         *) delFile $@
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
