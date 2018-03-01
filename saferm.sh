#!/bin/bash
# this is a test project
currentPath=$(pwd)
currentItem=$1
itemPath=$currentPathD/$currentItem
trashPath="$HOME/.Trash_Saferm"

#FUNCTIONS
moveFile(){
  mv "$1" $trashPath
}
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
                  echo "Yo have declined to remove $1, please try again"
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

          for object in $totalItems
          do

              # echo "looping again"
              if [[ -f "$currentdir/$object" ]]
              then
                # echo "$object is a file"
                  moveItem $currentdir/$object
              else
                    dirContentsCheck=$(ls -l "$currentdir/$object" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' | wc -l | xargs)
										echo " "
										read -p "Do you want to examine files in directory $currentdir/$object? " response
                    if [[ $response == Y* || $response == y* ]]
                    then
                       if [[ $dirContentsCheck -gt 0 ]]
                       then
                        interateDir $currentdir/$object
                      else
                        moveFileItem $currentdir/$object
                      fi

                    else
                        echo "$currentdir/$object not examined"
                    fi

              fi
          done
           backOneStep $currentdir/$object

           currentdir=$(dirname $currentdir)

}
# FOR FILES
if [[ -f "$currentItem" ]];
then
    moveItem $currentItem
fi

#FOR DIRECTORIES
if [[ -d "$1" ]];
then
        echo ""
      read -p "Do you want to examine files in directory $1? " response
     if [[ $response == Y* ]] || [[ $response == y* ]]
     then
        interateDir $1
     else
         echo "Request to examine $1 declined"
     fi
fi
