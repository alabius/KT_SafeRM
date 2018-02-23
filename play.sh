#!/bin/bash
#create variables
home="$HOME"
trashName=".Trash_saferm"
trashPath="$home/$trashName"

#create function for move file
moveFile() {
	mv $1 $trashPath
}
movedir(){
	mv  "$1" $trashPath
}
isDirectoryEmpty(){

    if [[ $( ls $1 | wc -l | xargs ) -gt 0 ]]; then
        true
    else
        false
    fi
}
pathIsFile(){
    if [[ -f $1 ]];
		then
			true
		else
			false
		fi
}
isYes(){
    [[ $1 =~ ^[y/Y]$ ]]
}
#adding function for checking if directory is empty

echo $( isDirectoryEmpty $1 )
#adding function for checking if directory exists at path if not create it
if [[ ! -d "$trashPath" ]]; then
  mkdir "$trashPath"
	echo "$trashName successfully create"
else
	echo " "
fi

pathIsFile $1
#Check if the item is a file or directory
if [[ $? -eq true ]]; then
  echo "Wao, do you know that $1 is a file?"
  #Check if its a file and User Input for Yes

  read -p "Do you want to remove $1? Y/N " response
  #if user reply Yes
  if isYes $response; then
      mv $1 $trashPath
      echo "$1 successfully removed"
      #if user reply no
  else
      echo "You just declined to remove $1"
  fi
else
  echo "Wao, do you know that $1 is a directory?"
  echo ""
  #ask to examine the directory
  read -p "Do you want $1 to be examined " response
  if isYes $response; then
    #check if the directory exist
    if [[ $( isDirectoryEmpty $1 ) -eq false ]]; then
        echo "Directory is empty"
        echo " "

        if [[ -d "$1" && $# -ne 0 ]]; then

      		#ask them if they want to enter the directory (if it is a directory)
      		read -p "examine files in directory $1? " response

      		#if the first letter of the response is upper or lower case Y
      		if [[ ${response:0:1} == 'y' || ${response:0:1} == 'Y' ]]
      		then
      			currentDir="$1"
      			true
      		else
      			false
      		fi
        fi
        read -p "do you want to remove $1? " response
        #if user response is yes
        if isYes $response; then
            mv $1 $trashPath
            echo "$1 successfully removed"
        else
            echo "$1 not removed"
        fi
    elif sDirectoryEmpty $1;then
      # examine each file
      ls $1
      for i in $( ls $1 ); do
        # Ask the user to delete the directory
        read -p "do you want to remove $i? " response
        #if user response is yes
        if isYes $response; then
            mv $1 $trashPath
            echo "$1 successfully removed"
          elif [[ $response =~ ^[n*/N*]$ ]]; #if user response is no
          then
              echo "You just declined to remove $1"
          else
              echo "error"
        fi
      done
    fi
  else
      echo "why don't you want me to examine $1"
  fi
  #loop through each directory
fi
#If file, Ask if file you want to delete the file
#If yes, Remove File, Else Do nothing
#If Directory, Ask if you want to examine the directory
#if Yes, check if the directory is empty,
#If not empty, check if there is file, if yes, call actions on file
#If no, ask if he want to remove directory
#If yes, remove directory
#repeat process until directory is empty and come out.
