#!/bin/bash
home=$HOME
trashName=".Trash_saferm"
trashPath="$home/$trashName"
currentPath=$1
# itemListing=$(ls -l "$currentPath")
loopArray[0]='.'
loopCount=0
dirCount=$( ls -l "$1" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' | wc -l | xargs)
dirItems=$(ls -l "$1" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' )

if [ ! -d "trashPath" ];
then
  mkdir "trashPath"
  echo "$trashName successfully created"
fi
#function for Directory or File Checking
ifFileOrDir(){
    if [[ -f "$1" ]]
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
    read -p "do you want to remove $1? " response
    #if the first letter of the reply is lower or upper case Y
    if isYes;
    then
        mv "$1" $trashPath
        echo "$1 removed"
    #else if the first letter of the reply is lower or upper case N
    else
        echo "Request declined"
    fi
}

#Code to handle directory
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
        presentPath=$1
        echo $dirCount
        if [[ $dirCount -gt true ]]
        then
            echo "This directory is not empty"
            for i in $dirItems; do

                #check if item is a file or directory
                ifFileOrDir "$presentPath/$i"

                if [[ $i -eq true ]]
                then
                        forFiles "$presentPath/$i"
                else

                  forDirectories "$presentPath/$i"

                  # #handle caller
                  # forFiles "${loopArray[$loopCount]}"
                  # move back one folder
                  loopCount=$((loopCount-1))
                fi
            done
        else
            echo "This directory is empyt"
            #delete the directory
            forFiles $presentPath/$i
            presentPath=$(dirName $presentPath)
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
