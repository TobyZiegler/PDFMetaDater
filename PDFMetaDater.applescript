#
# PDFMetaDater
#
# Applescript to change creation and modification dates of a PDF to match internal properties.
#
# Created by Toby Ziegler, February 22 2023
# Last updated by Toby on March 19, 2023
#
#
# Designating this script as version 0.5.1
#
--current version message:
--rearranged to move change handler to be accessible both drag-and-drop and run

# Files may be dialog designated or drag-and-drop, beginning dnd process
# Internal properties can be obtained with ExifTool
# Dates are converted to touch-friendly values
# File creation and modification dates use touch command
#

#
# Script now relies on ExifTool being installed:
# brew install exiftool
#

-- currently limmited to PDFs, unknown how well exiftool may work with other formats
property theFileTypesToProcess : {"PDF"}
property theExtensionsToProcess : {"pdf"} -- I.e. {"txt", "text", "jpg", "jpeg"}, NOT: {".txt", ".text", ".jpg", ".jpeg"}
--killing property type, not needed I think? if needed, will need to re-reference source
--property theTypeIdentifiersToProcess : {} -- I.e. {"public.jpeg", "public.tiff", "public.png"}



########## BEGIN MAIN ##########


set selectedFile to setFile()

changeFile(selectedFile)

########### END MAIN ###########

on changeFile(sourceFile)
	
	--confirm starting values, remove for completed code
	confirm(sourceFile)
	
	set metaCreateDate to readDate(sourceFile, "CreateDate")
	
	set metaModDate to readDate(sourceFile, "ModifyDate")
	
	changeDates(sourceFile, metaCreateDate, metaModDate)
	
	--confirm ending values, remove for completed code
	confirm(sourceFile)
	
end changeFile




(* Credit and Reference for drop code:
https://developer.apple.com/library/archive/documentation/LanguagesUtilities/Conceptual/MacAutomationScriptingGuide/ProcessDroppedFilesandFolders.html#//apple_ref/doc/uid/TP40016239-CH53-SW1
*)

on open theDroppedItems
	repeat with a from 1 to count of theDroppedItems
		set theCurrentItem to item a of theDroppedItems
		tell application "Finder"
			set isFolder to folder (theCurrentItem as string) exists
		end tell
		
		-- Process a dropped folder
		if isFolder = true then
			processFolder(theCurrentItem)
			
			-- Process a dropped file
		else
			processFile(theCurrentItem)
		end if
	end repeat
end open

on processFolder(theFolder)
	-- NOTE: The variable theFolder is a folder reference in AppleScript alias format
	-- Retrieve a list of any visible items in the folder
	set theFolderItems to list folder theFolder without invisibles
	
	-- Loop through the visible folder items
	repeat with a from 1 to count of theFolderItems
		set theCurrentItem to ((theFolder as string) & (item a of theFolderItems)) as alias
		open {theCurrentItem}
	end repeat
	-- Add additional folder processing code here
end processFolder

on processFile(theItem)
	-- NOTE: variable theItem is a file reference in AppleScript alias format
	tell application "System Events"
		set theExtension to name extension of theItem
		set theFileType to file type of theItem
	end tell
	if ((theFileTypesToProcess contains theFileType) or (theExtensionsToProcess contains theExtension)) then
		
		-- Add file processing code here
		changeFile(theItem)
		
		display dialog theItem as string
	end if
end processFile





on readDate(theFile, theType)
	
	--the chosen file path comes as an alias and must be converted
	--set thePath to POSIX path of theFile
	##path now converted at choosing in setFile()
	
	--the shell command "exiftool" reads the named property
	--exiftool is not recognized without setting the path
	set theScript to "PATH=/usr/local/bin:$PATH; " & "exiftool -" & theType & " " & theFile
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
	set theRefinedDate to text 35 thru 38 of theMetaDate & text 40 thru 41 of theMetaDate & text 43 thru 44 of theMetaDate & theNewHour & text 49 thru 50 of theMetaDate & "." & text 52 thru 53 of theMetaDate
	log theRefinedDate
	
	
	
	return theRefinedDate
	
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

on changeDates(theFile, createDate, modDate)
	
	--use the shell command "touch" or "SetFile"
	--SetFile -d for creation and SetFile -m for modification
	--Format: SetFile -d mm/dd/[yy]yy [hh:mm[:ss] [AM | PM]] filelocation
	##turns out SetFile is deprecated
	
	--touch -t changes access, modification and creation dates
	--touch -t yyyymmddhhmm [pathtofile][filename]
	set theScript to "touch -t " & createDate & " " & theFile
	do shell script theScript
	log "Create: " & createDate
	confirm(theFile)
	
	
	--touch -amt changes the access and modified dates, leaving the creation date
	--touch -amt yyyymmddhhmm [pathtofile][filename]
	set theScript to "touch -amt " & modDate & " " & theFile
	do shell script theScript
	log "Modify: " & modDate
	confirm(theFile)
	
end changeDates

on setFile()
	
	try
		set thePath to choose file with prompt "Please choose the target PDF:"
		log thePath
		set theFile to POSIX path of thePath
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