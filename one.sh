#!/bin/bash

homeDir="$HOME"
trashSafermDirName=".Trash_saferm"
trashSafermPath="$homeDir/$trashSafermDirName"
srmTrue="0"
srmFalse="1"
rootDir=$1
currentDir="$rootDir"
treeDepth=-1
treeDepthIterationArray[0]=1

#adding function for checking if directory exists at path
doesDirectoryExist(){
    if [ ! -d "$2/$1" ]; then
        mkdir "$2/$1"
        echo "Created Directory $2/$1 because it didn't previously exist"
    fi
}


createTrashSafeRMDir(){
    doesDirectoryExist $trashSafermDirName $homeDir
}

isResponseYes(){

	response="$1"

	#if the first letter of the response is upper or lower case Y
	if [[ ${response:0:1} == 'y' || ${response:0:1} == 'Y' ]]
	then
		true
	else
		false
	fi

}


#returns a boolean value
shouldEnterDirectory(){

	if [[ -d "$1" && $# -ne 0 ]]
	then

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

	else

		echo "usage: saferm [-drv] file ..."
		echo "	unlink file"
		false
	fi
}


finalDeleteOfDirectory(){

	read -p "remove $1? " response

	isResponseYes $response

	#if the user resopnds yes to the directory removal prompt
	if [ $? -eq $srmTrue ]
	then

		treeDepth=$((treeDepth - 1))

		directoryContentsCount=$(ls -l "$1" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' | wc -l | xargs)

		#if the count of the items in the directory is GREATER THAN 0 then
		if [ $directoryContentsCount -gt 0 ]
		then
			echo "saferm: $1: Directory not empty"
		else
			#otherwise move the file at the specific path to the safe_rm recycle bin
			mv "$1" $trashSafermPath
		fi

	fi

}



recursivelyDeleteContentsOfDirectory(){

    shouldEnterDirectory "$1"

	#if the user has chosen to enter the directory
	if [ $? -eq $srmTrue ]
	then
		#currentDir is whatever the first parameter is
		currentDir="$1"
		treeDepth=$((treeDepth + 1))
		#get total list of files and directories (IN THAT ORDER)
		totalItemListing=$(ls -l "$currentDir" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' )
		#set the iterations remaining in the depth array for this depth
		treeDepthIterationArray[$treeDepth]=$(echo "$totalItemListing" | wc -l | xargs)

		#loop through every item asking if the user wants to delete it
		for item in $totalItemListing
		do

			#if the current item in the iteration is a FILE
			if [ -f "$currentDir/$item" ]
			then

				read -p "remove $item? " response
				isResponseYes $response

				#if the user resopnds yes to the file removal prompt
				if [ $? -eq $srmTrue ]
				then
					mv "$currentDir/$item" $trashSafermPath
					totalItemsRemaining=$((totalItemsRemaining - 1))
				fi

			fi

#======================================================================================================

			#if the current item in the iteration is a DIRECTORY
			if [ -d "$currentDir/$item" ]
			then
				recursivelyDeleteContentsOfDirectory "$currentDir/$item"
			fi

			#reduce the number of iterations remaining by 1
			treeDepthIterationArray[$treeDepth]=$(( ${treeDepthIterationArray[$treeDepth]} - 1 ))

			#it the number of iterations remaining are equal to zero
			if [ ${treeDepthIterationArray[$treeDepth]} -eq 0 ]
			then
				#name of the directory being worked on (Parent directory)
				workingDir=$(basename "$currentDir")
				#PATH of the directory being worked on
				currentDir=$(dirname "$currentDir")
				#this function prompts the final deletion of a directory and handles its response
				finalDeleteOfDirectory "$currentDir/$workingDir"
			fi

		done

		#when all iterations are complete ask if you want to delete the root folder you started with
		if [[ $treeDepth -eq 0 && ${treeDepthIterationArray[$treeDepth]} -eq 1 ]]
		then
			finalDeleteOfDirectory "$rootDir"
		fi

	fi

}

#code to Create the trash directory if it doesn't already exist
createTrashSafeRMDir

recursivelyDeleteContentsOfDirectory $1
