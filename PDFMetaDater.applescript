#
# PDFMetaDater
#
# Applescript to change creation and modification dates of a PDF to match internal properties.
#
# Created by Toby Ziegler, February 22 2023
# Last updated by Toby on March 8, 2023
#
#
# Designating this script as version 0.2.2
-- version notes:
-- Turns out the mdls command accesses a lot of data, but not the data shown in the properties from inside Adobe Acrobat. Instead, it is showing system properties.
#

# Script now relies on ExifTool being installed:
# brew install exiftool
#

# initialize variables -- no global variables yet, delete if never


########## BEGIN MAIN ##########


set sourceFile to setFile()
--set targetFolder to setFolder("target")
set metaCreateDate to readDate(sourceFile, "CreateDate")
set metaModDate to readDate(sourceFile, "ModifyDate")
changeDates(metaCreateDate, metaModDate)

confirm(sourceFile)


########### END MAIN ###########


on readDate(theFile, theType)
	
	--the chosen file path comes as an alias and must be converted
	set thePath to POSIX path of theFile
	
	--the shell command "mdls -name" reads a specific metadata by name
	#set theScript to "mdls -name kMDItemContent" & theType & "Date " & thePath
	(* keeping the mdls text for now. It works, but just doesn't get the info we want *)
	
	--the shell command "exiftool" reads the named property
	set theScript to "exiftool -" & theType & " " & thePath
	log "theScript: " & theScript
	
	--after building the script, just run it!
	set theMetaDate to do shell script theScript -- throws sh: exiftool: command not found number 127, but script runs perfectly in terminal
	
	--dates arrive in metadata format and must be parsed
	
	return theMetaDate
	
	#
	# Note:
	#
	# need three exiftool dates:
	# CreateDate
	# MetadataDate
	# ModifyDate
	#
	# these correspond to:
	# FileInodeChangeDate (?)
	# FileAccessDate
	# FileModifyDate
	#
	
end readDate

on changeDates(createDate, modDate)
	
	--use the shell command "touch" or something?
	
	--touch -mt 202303110700.00 /path/to/file--for changing the modification date
	--
	
	(*
	Use setFile to change the origination date:
	SetFile -d '12/31/1999 23:59:59' file.txt
            MM dd yyyy hh mm ss  fileName
			*)
	
	
end changeDates

on setFile()
	
	try
		set theFile to choose file with prompt "Please choose the target PDF:"
		log theFile
		return theFile
	end try
	
end setFile

on confirm(theSource)
	
	--run shell command "stat" to confirm final system dates
	set theCheckScript to "stat -f 'Access (atime): %Sa%nModify (mtime): %Sm%nChange (ctime): %Sc%nBirth  (Btime): %SB' " & the POSIX path of theSource
	
	set theConfirmation to do shell script theCheckScript
	log "Confirmation: " & linefeed & theConfirmation
	
	#
	# Note:
	#
	# atime = Access Time = when file was last opened
	# mtime = Modify Time = when file was last changed
	# ctime = Change Time = when file's meta was last changed, including permissions, etc.
	# btime = Birth Time = when file first created
	#
	
end confirm