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
function movedir {
	mv $pathFile $trashPath
}
#Check if ~/.Trash_saferm exists, if it doesn't, then create it
	if [[ ! -d "$trashPath" ]]; then
        mkdir "$trashPath"
		echo "$trashName successfully create"
	else
		echo
	fi
#check if item to be deleted is a file or directory
	if [[ -f $pathFile ]]; then
        echo "Wao, do you know that $pathFile is a file?"
				echo
#Check User Input for Yes
read -p "Do you want to remove $pathFile? Y/N " -n 2 -r
if [[ $REPLY =~ ^[y/Y]$  ]];
	then
		moveFile
		echo "$pathFile removed"
elif [[ $REPLY =~ ^[n/N]$ ]];
	then
		echo "You just declined to remove $pathFile"
else
	echo
fi
fi
