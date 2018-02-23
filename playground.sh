#!/bin/bash

#declare variables
hom="$HOME"
trashName=".Trash_saferm"
trashPath="$home/$trashName"
responseTrue="0"
responseFalse="1"
rootPath=$1
currentPath="$rootPath"
dirDept=-1
dirDeptIterationArray[0]=1

#Checking if directory exist
pathExist(){
  if [ ! -d "$2/$1" ]; then
    mkdir "$2/$1"
    echo "$2/$1 successfully created"
  fi
}
#Create Trash_saferm
creatTrash(){
  pathExist $trashName $home
}
#Check for user reply to be y or Y
isYes(){
  #if the reply corresponse to y or Y
  if [[ $1 =~ ^[y/Y]$ ]]
  then
    true
  else
    false
  fi

}
#Ask if to enter directory
enterDirectory(){

	if [[ -d "$1" && $# -ne 0 ]]
	then

		#ask them if they want to enter the directory (if it is a directory)
		read -p "examine files in directory $1? " response

		#if the first letter of the response is upper or lower case Y
		if [[ ${response:0:1} == 'y' || ${response:0:1} == 'Y' ]]
		then
			currentPath="$1"
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
#Get the action to remove directory
finalDeleteOfDirectory(){

	read -p "Do you want to remove $1? " response

	isYes $response

	#if the user resopnds yes to the directory removal prompt
	if [ $? -eq $responseTrue ]
	then

		dirDepth=$((treeDepth - 1))

	  countDir=$(ls -l "$1" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' | wc -l | xargs)

		#if the count of the items in the directory is GREATER THAN 0 then
		if [ $countDir -gt 0 ]
		then
			echo "saferm: $1: Directory not empty"
		else
			#otherwise move the file at the specific path to the safe_rm recycle bin
			mv "$1" $trashPath
		fi

	fi

}
recursivelyDelete(){

enterDirectory "$1"

	#if the user has chosen to enter the directory
	if [ $? -eq $responseTrue ]
	then
		#currentDir is whatever the first parameter is
		currentPath="$1"
		dirDepth=$((treeDepth + 1))
		#get total list of files and directories (IN THAT ORDER)
		totalItemListing=$(ls -l "$currentPath" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' )
		#set the iterations remaining in the depth array for this depth
		dirDeptIterationArray[$dirDepth]=$(echo "$totalItemListing" | wc -l | xargs)

		#loop through every item asking if the user wants to delete it
		for item in $totalItemListing
		do

			#if the current item in the iteration is a FILE
			if [ -f "$currentPath/$item" ]
			then

				read -p "Do you want to remove $item? " response
				isYes $response

				#if the user resopnds yes to the file removal prompt
				if [ $? -eq $responseTrue ]
				then
					mv "$currentPath/$item" $trashPath
					totalItemsRemaining=$((totalItemsRemaining - 1))
				fi

			fi
      #if the current item in the iteration is a DIRECTORY
      			if [ -d "$currentPath/$item" ]
      			then
      				recursivelyDeleteContentsOfDirectory "$currentPath/$item"
      			fi

      			#reduce the number of iterations remaining by 1
      			treeDepthIterationArray[$dirDepth]=$(( ${dirDeptIterationArray[$treeDepth]} - 1 ))

      			#it the number of iterations remaining are equal to zero
      			if [ ${dirDeptIterationArray[$dirDepth]} -eq 0 ]
      			then
      				#name of the directory being worked on (Parent directory)
      				workingDir=$(basename "$currentPath")
      				#PATH of the directory being worked on
      				currentDir=$(dirname "$currentPath")
      				#this function prompts the final deletion of a directory and handles its response
      				finalDeleteOfDirectory "$currentPath/$workingDir"
      			fi

      		done

      		#when all iterations are complete ask if you want to delete the root folder you started with
      		if [[ $dirDepth -eq 0 && ${dirDeptIterationArray[$dirDepth]} -eq 1 ]]
      		then
      			finalDeleteOfDirectory "$rootPath"
      		fi
      	fi

      }

      #code to Create the trash directory if it doesn't already exist
      creatTrash
      recursivelyDelete $1
