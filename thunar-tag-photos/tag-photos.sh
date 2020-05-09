#!/bin/bash


# To use, set as custom thunar action:
# <path to file>/tag-photos.sh %F
# with filter *.jpg;*.JPG

#TODO: check exiftool & zentiy  is installed 

LOGFILE=/tmp/image-tag-update-$USERNAME.log

echo "" >>$LOGFILE
echo `date` >>$LOGFILE

TAG=`zenity --forms --title="Tags" --text="What tag would you like to set?" --add-entry="Tag" `
echo "TAG: $TAG Files: $@ ($#)"  >>$LOGFILE

# If TAG is not specified, exit
if [ !-n "$TAG" ]  
 then
	echo "No tag">>$LOGFILE
	zenity --warning --text="No tag supplied."
	exit 1
fi	


SCOUNT=0
DCOUNT=0
FCOUNT=0
ICOUNT=0

# TODO: If just one image, read the tag first and pre-fill input box

for file in "$@"
 do
	#TODO: check that we can write to each file before executing
	echo $(($ICOUNT * 100 / $#))
	ICOUNT=$(($ICOUNT+1))

	exiftool -Keywords "$file" |grep $TAG
	RV=$?
	if [ "$RV" -ne "1" ]
	 then
		#check if the tag already exists and if so, skip this item
		#TODO: Do this properly by expanding the comma array of keyworda and parsing it for the tag
		DCOUNT=$(($DCOUNT+1))
		echo "Tag $TAG already exists for file $file, skipping ($DCOUNT)" >>$LOGFILE
		continue
	fi


	echo "CMD: exiftool -overwrite_original -keywords+=$TAG $file" >>$LOGFILE
	#RESULT=`exiftool -overwrite_original -keywords+=$TAG "$file"`
	RESULT=`exiftool -overwrite_original_in_place -keywords+=$TAG "$file"`
	RV=$?


	if [ "$RV" -ne "0" ]
	 then
		echo "RV(exiftool): $RV $RESULT" >>$LOGFILE
		FCOUNT=$(($FCOUNT+1))
		zenity --error --text="An error occurred when updating $file: $RESULT ($FCOUNT)"
		continue
	 else
		SCOUNT=$(($SCOUNT+1))
		echo "RV(exiftool): $RV $RESULT ($SCOUNT)" >>$LOGFILE
	fi
## Use a process substitution "> >" rather than a pipe to preserve the variables
done > >(zenity  --progress --title "Tagging images..." --text="Updating $# images" --percentage=0 --auto-close --auto-kill)

echo "Summary: $#: $SCOUNT / $DCOUNT / $FCOUNT "  >>$LOGFILE
zenity --title="Image tag update summary" --info --text "Of $# files:\n - $SCOUNT files updated with tag $TAG \n - $DCOUNT already had the tag $TAG\n - $FCOUNT files failed."

