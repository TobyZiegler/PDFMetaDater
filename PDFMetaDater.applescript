#
# PDFMetaDater
#
# Applescript to change creation and modification dates of a PDF to match internal properties.
#
# Created by Toby Ziegler, February 22 2023
# Last updated by Toby on March 15, 2023
#
#
# Designating this script as version 0.3.4
-- Internal properties can be obtained with ExifTool
-- File creation and modification dates will use touch command
-- Dates are converted to touch-friendly values
#

#
# Script now relies on ExifTool being installed:
# brew install exiftool
#

# initialize variables -- no global variables yet, delete if never


########## BEGIN MAIN ##########


set sourceFile to setFile()

set metaCreateDate to readDate(sourceFile, "CreateDate")

set metaModDate to readDate(sourceFile, "ModifyDate")

changeDates(metaCreateDate, metaModDate)

confirm(sourceFile)


########### END MAIN ###########


on readDate(theFile, theType)
	
	--the chosen file path comes as an alias and must be converted
	set thePath to POSIX path of theFile
	
	--the shell command "exiftool" reads the named property
	--exiftool is not recognized without setting the path
	set theScript to "PATH=/usr/local/bin:$PATH; " & "exiftool -" & theType & " " & thePath
	## will probably need to check if exiftool is installed, then offer to install it if not
	
	
	--after building the script, just run it!
	set theMetaDate to do shell script theScript
	log "MetaDate = " & theMetaDate
	
	--dates arrive in metadata format and must be parsed
	--since we will use touch later on, that should be the target format
	
	(* Formats:
	Create Date                     : 2018:06:07 14:57:15-05:00
	Modify Date                     : 2018:06:07 14:57:15-05:00
	*)
	
	-- Convert the date string to touch format (YYYYMMDDhhmm.ss)
	-- Start by adjusting for GMT
	set theHour to text 46 thru 47 of theMetaDate as number
	log "the Hour: " & theHour
	set theGMTchange to text 54 thru 56 of theMetaDate as number
	log "the GMT: " & theGMTchange
	set theNewHour to theHour + theGMTchange
	log "the Result: " & theNewHour
	
	--the new value could easily be a single digit, test and modify if so
	set digitCount to the length of (theNewHour as string)
	if digitCount is less than 2 then
		set theNewHour to "0" & theNewHour
	end if
	
	
	--first try:
	--set newDate to text 35 thru 38 of theMetaDate & text 40 thru 41 of theMetaDate & text 43 thru 44 of theMetaDate & text 46 thru 47 of theMetaDate & text 49 thru 50 of theMetaDate & "." & text 52 thru 53 of theMetaDate
	
	--second try with GMT adjustment
	set newDate to text 35 thru 38 of theMetaDate & text 40 thru 41 of theMetaDate & text 43 thru 44 of theMetaDate & theNewHour & text 49 thru 50 of theMetaDate & "." & text 52 thru 53 of theMetaDate
	log newDate
	
	
	
	return theMetaDate
	
	(*
	Note:
	
	need three dates:
	  CreateDate
	  ModifyDate
	  MetadataDate
	
	these correspond to exiftool values for:
	  Create Date
	  Modify Date
	  FileAccessDate??
	
	*)
	
end readDate

on changeDates(createDate, modDate)
	
	--use the shell command "touch" or "SetFile"
	--SetFile -d for creation and SetFile -m for modification
	--Format: SetFile -d mm/dd/[yy]yy [hh:mm[:ss] [AM | PM]] filelocation
	##turns out SetFile is deprecated
	
	--touch to change the creation date
	--touch -mt yyyymmddhhmm [pathtofile][filename]
	log "Create: " & createDate
	
	--touch to change the modified date
	--touch -t yyyymmddhhmm [pathtofile][filename]
	log "Modify: " & modDate
	
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
	
	(*
	Note:
	
	for the stat command,
	  atime = Access Time = when file was last opened
	  mtime = Modify Time = when file was last changed
	  ctime = Change Time = when file's meta was last changed, including permissions, etc.
	  btime = Birth Time = when file first created
	
	*)
	
end confirm