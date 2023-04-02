# PDFMetaDater
Applescript to change creation and modification dates of a PDF to match internal properties.

When downloading PDFs through many mediums, though most prominently ine email, the creation and modification dates are changed to match the moment of download, not the dates the file had before uploading.

This script is an attempt to read the metadata of any given PDF and update that file's system creation and modification dates to match the metadata.

The script utilizes standard AppleScript wherever possible, wich turns out to be most of the code, with shell scripts used to execute the fiddley bits of reading the metadata and writing new dates.

Research discovered the terminal command "mdls" reads PDF metadata quite thoroughly. The two most relevant items are kMDItemFSCreation for the meta creation date and kMDItemLastUsed for the meta modification date. The "onReadDate" subroutine builds the information needed for the shell script, then executes the shell script with a single variable, loading the results for return.

Currently, the source files are selected via dialog using AppleScript's Alias reading ability, then the location is converted to POSIX format for the shell script to understand.

Following this, the file is read, then the information transferred to the file's system data.