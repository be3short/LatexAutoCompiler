#######################################################################################
# Latex Auto PDF Compiler - Author: Brendan Short - Version: 1.0 : 2/4/2017
#######################################################################################
# This program re-compiles a latex project into a pdf every time that a file within the 
# base project directory is modified.  The directory that this script is located in
# must be the base project directory, meaining this directory contains all the files 
# (they can be in sub-directories) that are to be monitored for updates.  The main tex
# file name needs to be supplied as an imput without the extension (ie .tex or .log) 
# and the path needs to be supplied as well if this main tex file is in a subdirectory
# (not directly located in the base directory).  Once this script is run, every time a 
# file is modified, the project will recompile.  For questions or comments feel free to
# email brendan.e.short@gmail.com. Enjoy!
#######################################################################################

#!/bin/sh
mainPath=$( cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P ) # path of base directory
texfileName="$1" # name of latex project files ie "Paper" would be the tex file name of a project that compiles from Paper.tex
texFileDirectory="$2" # path to main latex project ie MainTex/ would be the path if the project tex files were located in sub-directory MainTex
currentDir="./" # variable to store the current directory when scanning all subdirectories
changeOccurred="" # flag indicating if change has occured and re-compile is needed
logFile="$texfileName.log" # log file name - used to get time of last compile
mainTexFile="$texfileName.tex" # main tex file name - tex file to run compile on

checkForFileChanges() # function to check through all files in the base directory, including the files in all subdirectories subdirectories 
{
	if [ -z "$changeOccurred" ];then # no change has been detected

		for filen in * # iterate through all files within the current directory
		do
			if [ -d "$filen" ];then # the file is a directory

				cd "$filen" # go to the next sub-directory

				currentDir="$currentDir/.." # store the relative path back to the directory scanned

				checkForFileChanges # check if any files in the directory have been updated
				cd ..
				currentDir="$tempDir" # return to the directory being scanned

			else # the file is a file
				
				if [ "$filen" -nt "$mainPath/$texFileDirectory$logFile" ];then # the file has been modified more recently than the last compile

					changeOccurred="yes" # set the change occurred flag 
				fi
			fi
		done
	fi
}

while true # infinite loop 
do
  checkForFileChanges # check for file changes

  if [ -n "$changeOccurred" ]; then # if a file change has occurred
  	
  	echo "Update detected, recompiling..." # print message to screen

  	cd "$mainPath/$texFileDirectory" # go to the tex file directory

  	pdflatex -halt-on-error "$mainTexFile" # compile the file (and break script if compile error occurs)
  	
  	changeOccurred="" # reset change flag

  	cd "$mainPath" # return to the main directory

  	echo "Compile attempt complete, listening for next update..." # print message to screen
  fi

sleep .05 # put the script to sleep to save resources, no reason to check for changes more than 20 times per second

done


