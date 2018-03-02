#!/bin/bash
# This is a project and program to emulate the "rm" command in UNIX.
# The name of the script would be Safe RM
# short command would be srm

# Define my variavle for directory and file
loopArray[0]='.'
loopCount=0
dirCount=$( ls -l "$@" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' | wc -l | xargs)
dirItems=$(ls -l "$@" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' )
currentPath=$(pwd)
currentItem=$@
itemPath=$currentPath/$currentItem

# INITIALIZE VARIABLES FOR OPTIONS AVAILABLE
OPT=-
NO_ARGS=0
FLAG_R=""
FLAG_F=""
FLAG_I=""
FLAG_V=""
FLAG_D=""

# Create variable to hold TRASH DIRECTORY
TRASH=$HOME/.Trash_saferm

#  CREATE TRASH FOLDER
if ! [ -d "$HOME/.Trash_saferm" ]
	then
		mkdir $HOME/.Trash_saferm
fi

# Move one step backwards after iteration
backOneStep(){
	dirContentsCheck=$(ls -l "$currentdir" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' | wc -l | xargs)
	read -p "remove  $currentdir? " response
	if [[ $response == Y* || $response == y* ]] && [[ $dirContentsCheck -eq 0 || $dirContentsCheck -gt 0 ]]
	then
		echo "srm: $currentdir is a directory"
	else
		echo " "
	fi
}
# Recursive process for nested directories
interateDir(){
	currentdir="$1"
	totalItems=$(ls -l "$currentdir" | sort -k1,1  | awk -F " " '{print $NF}' | sed -e '$ d')
		for i in $totalItems
		do
		if [[ -f "$currentdir/$i" ]]
		then
			forFiles $currentdir/$i
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
					echo "srm: $@ is a directory"
				fi
			else
				echo " "
			fi
		fi
		done
	backOneStep $currentdir/$i
	currentdir=$(dirname $currentdir)
}

# confirm if response is YES or NO
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
	echo " "
	#If the response if another other thing other than Y or y
	else
		echo " "
	fi
}

# Function for options d when the directory is not empty
function dirNotEmpty(){
  dirCount=$( ls -l "$@" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' | wc -l | xargs)
  if [[ -f "$1" ]];
  then
    forFiles $@
  elif [[ $dirCount -gt 0 ]]
  then
    echo "srm: Directory not empty "
    exit 0
  else
    delFile $@
  fi
}

# Function for options i
function dOption(){
	if [[ -f "$1" ]]; then
		verbose $@
	else
		echo "srm: $@ is a directory"
	fi
}

# Function for options i
function vOption(){
	if [[ -f "$1" ]]; then
		verbose $@
	else
		echo "srm: $@ is a directory"
	fi
}

#Function for options i
function iOption(){
	if [[ -f "$1" ]]; then
		int $@
	else
		echo "srm: $@ is a directory"
	fi
}

#Function for options f
function fiOption(){
	if [[ -f "$1" ]]; then
		mv $OPTS $@ $TRASH 2>/dev/null
	else
		echo "srm: $@ is a directory"
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
	echo "try \`srm -help\` for more information"
	exit 0
}

#function to handle errors when option supplied do not match
function errorTooFew() {
	echo "srm: too few arguments"
	echo "try \`srm --help\` for more information"
}

#function to handle errors when argument supplied do not exist
function errorNoSuch() {
	echo "srm: $* is not a valid file or directory"
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
	echo -n "remove $*? "
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
		echo " "
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
                         d) dirNotEmpty $@
                          break
                          ;;
                         u) undo $@
                          break
                          ;;
                         *) iOption $@
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

# FLOW CONTROL for all flags to be used
OPTS=$FLAG_R$FLAG_F$FLAG_I$FLAG_V$FLAG_D$FLAG_U

#check if there is any supplied arguments
if [ "$#" -eq "$NO_ARGS" ] ; then
   errorTooFew $@
elif ! [ -f  "$1" ] &&  ! [ -d "$1" ]; then
   errorNoSuch $@
else
   delete $@
fi
