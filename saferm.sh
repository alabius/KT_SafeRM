#!/bin/bash
#create variables 
home="$HOME"
trashName=".Trash_saferm"
trashPath="$home/$trashName"
pathFile=$1
#create function for move file
function moveFile {
	mv $pathFile $trashPath
}
#Check if ~/.Trash_saferm exists, if it doesn't, then create it
	if [[ ! -d "$trashPath" ]]; then
        mkdir "$trashPath"
		echo "$trashName successfully create"	
	else
		echo "$trashName already exit"	
	fi
#check if item to be deleted is a file or directory
	if [[ -f $pathFile ]]; then
        echo "$pathFile is a file"
#Check User Imout for Yes
		read -p "are you sure you wan to delete $pathFile" response
        elif [[ $response =~ ^[y/Y]$ ]]
            then
				moveFile
                echo "$pathFile Moved"
	else
		echo "$pathFile is a directory"
	fi
