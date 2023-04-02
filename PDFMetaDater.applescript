#
# PDFMetaDater
#
# Applescript to change creation and modification dates of a PDF to match internal properties.
#
# Created by Toby Ziegler, February 22 2023
# Last updated by Toby on March 7, 2023
#
#
# Designating this script as version 0.2
#
#

set sourceFile to setFile()
--set targetFolder to setFolder("target")
set metaCreateDate to readDate(sourceFile, "FSCreation")
set metaModDate to readDate(sourceFile, "LastUsed")
changeDates(metaCreateDate, metaModDate)

--run shell command "stat" to confirm final dates
--stat -f "Access (atime): %Sa%nModify (mtime): %Sm%nChange (ctime): %Sc%nBirth  (Btime): %SB" file.txt
set theCheckScript to "stat -f 'Access (atime): %Sa%nModify (mtime): %Sm%nChange (ctime): %Sc%nBirth  (Btime): %SB' " & the POSIX path of sourceFile

set theConfirmation to do shell script theCheckScript
log "Confirmation: " & theConfirmation

on readDate(theFile, theType)
	
	--the chosen file path comes as an alias and must be converted
	set thePath to POSIX path of theFile
	
	--the shell command "mdls -name" reads a specific metadata by name
	set theScript to "mdls -name kMDItem" & theType & "Date " & thePath
	
	--after building the script, just run it!
	set theMetaDate to do shell script theScript
	
	--dates arrive in metadata format and must be parsed
	
	return theMetaDate
	
	
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