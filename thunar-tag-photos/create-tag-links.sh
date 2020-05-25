#!/bin/bash

BASEPATH=/srv/fileshare/Media/Photos

IMAGEBASE=$BASEPATH
#IMAGEBASE=$BASEPATH/20171022/

LINKBASE=$BASEPATH/tag-index


# TODO: Check we have bins installed (exiftool etc)

COUNT=0

## find all jpgs, for each with any tags, store the name,  split the tags, create a folder as the tag name, create symlinks to each image under


for IMAGEFILE in `find $IMAGEBASE -iname *.jpg`
 do
	COUNT=$((COUNT + 1))
	TAGS=`exiftool -q -q -Keywords $IMAGEFILE |cut -f 2 -d :`
# TODO: This would be faster if we had an index with filename and mod date so we only examine changed files for tags

	if [ ! -z "${TAGS}" ]
	 then
		TAG_LIST=`echo $TAGS |tr , "\n" `
		for TAG in $TAG_LIST
# TODO: Bug - when tags have spaces, all parts are listed, so need to use a comma as separator, not re-split, and set/reset IFS
		 do
			LINKDIR=$LINKBASE/${TAG//[^A-Za-z0-9._-]/_}
			LINKDEST=$LINKDIR/`basename $IMAGEFILE`

			mkdir -p $LINKDIR

			if [ ! -f $LINKDEST ]
			 then
				echo " - Linking $IMAGEFILE to $LINKDEST"
				ln -s $IMAGEFILE $LINKDEST
			fi
		done
	fi
done




