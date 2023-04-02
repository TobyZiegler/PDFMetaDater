#
# PDFMetaDater
#
# Applescript to change creation and modification dates of a PDF to match internal properties.
#
# Created by Toby Ziegler, February 22 2023
# Last updated by Toby on March 8, 2023
#
#
# Designating this script as version 0.2
# Reading metadata looks like it works, now for the writing
#

# initialize variables -- no global variables yet, delete if never


########## BEGIN MAIN ##########


set sourceFile to setFile()
--set targetFolder to setFolder("target")
set metaCreateDate to readDate(sourceFile, "Creation")
set metaModDate to readDate(sourceFile, "Modification")
changeDates(metaCreateDate, metaModDate)

confirm(sourceFile)


########### END MAIN ###########


on readDate(theFile, theType)
	
	--the chosen file path comes as an alias and must be converted
	set thePath to POSIX path of theFile
	
	--the shell command "mdls -name" reads a specific metadata by name
	set theScript to "mdls -name kMDItemContent" & theType & "Date " & thePath
	
	--after building the script, just run it!
	set theMetaDate to do shell script theScript
	
	--dates arrive in metadata format and must be parsed
	
	return theMetaDate
	
	#
	# Note:
	#
	# kMDItemContentCreationDate		= creation date, Btime
	# kMDItemContentModificationDate	= modification date, mtime
	# kMDItemDateAdded				= added date
	# kMDItemFSContentChangeDate	= file system change date, ctime
	# kMDItemFSCreationDate			= file system creation date
	# kMDItemLastUsedDate			= access date, atime
	#
	
end readDate

on changeDates(createDate, modDate)
	
	--use the shell command "touch" or 
	
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