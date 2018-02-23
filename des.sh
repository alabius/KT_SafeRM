#!/bin/bash

trashName=".Trash_saferm"
trashPath="$HOME/$trashName"
currentPath=$1
itemListing=$(ls -l "$currentPath")
loopArray[0]='.'
loopCount=0

#function for Directory or File Checking
ifFileOrDir(){
    if [[ -f "${?}" ]]
    then
        true
    else
        false
    fi
}
isYes(){
  [[ $response =~ ^[y*/Y*]$ ]]
}
isNo(){
  [[ $response =~ ^[n*/N*]$ ]]
}
#Code to handle files
forFiles() {

    read -p "do you want to remove $1?" response
    #if the first letter of the reply is lower or upper case Y
    if isYes;
    then
        mv $1 $trashPath
        echo "$1 removed"
    #else if the first letter of the reply is lower or upper case N
  elif isNo;
    then
        echo "Request to move $1 declined"
    else
        echo "Not a valid file of directory"
    fi
}

#Code to handle files
forDirectories() {

    loopCount=$((loopCount+1))
    loopArray[$loopCount]=$1

    echo "$1 is a directory"
    echo " "
    read -p "Do you want to examine files in directory $1? " response

    #if the first letter of the reply is lower or upper case Y
    if isYes
    then
        #examine each file
        dirItems=$(ls -l "$1" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' )
        dirCount=$( ls -l "$1" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' | wc -l | xargs)
        nowPath=$1
        echo $dirCount
        if [[ $dirCount -gt true ]]
        then
            echo "This directory is not empty"

            for i in $dirItems; do

                #check if item is a file or directory
                ifFileOrDir "$nowPath/$i"

                if [[ $? -eq true ]]
                then
                        forFiles "$nowPath/$i"
                else

                  forDirectories "$nowPath/$i"

                  #handle caller
                  forFiles "${loopArray[$loopCount]}"
                      #move back one folder
                    loopCount=$((loopCount-1))
                fi
            done
        else
            echo "This directory is empyt"
            #delete the directory
            forFiles $nowPath
        fi

    fi

}
ifFileOrDir $1

if [[ $? -eq true ]]
then
    forFiles $1
else
    forDirectories $1
fi
