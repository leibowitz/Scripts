
SCRIPT_DIR=`dirname ${0}`

OUTPUT_DIRECTORY='' # default


MAX_PROCESSES=2




if [ $# -gt 0 ] ; then
	

	LAST_ARG="${@: -1}"
	if [ -d "$LAST_ARG" ] ; then
		OUTPUT_DIRECTORY="$LAST_ARG"
	fi

	ERROR_DIRECTORY="$OUTPUT_DIRECTORY"'/errors'
	SUCCESS_DIRECTORY="$OUTPUT_DIRECTORY"'/success'
	LOG_DIR="$OUTPUT_DIRECTORY"'/logs'

	if [ ! -d "$ERROR_DIRECTORY" ] ; then
		echo $ERROR_DIRECTORY" is not a directory"
		exit 1
	fi
	if [ ! -d "$SUCCESS_DIRECTORY" ] ; then
		echo $SUCCESS_DIRECTORY" is not a directory"
		exit 1
	fi
	if [ ! -d "$LOG_DIR" ] ; then
		echo $LOG_DIR" is not a directory"
		exit 1
	fi
	
	declare -a PIDS

	wait_jobs ()
	{
		for PID in ${!PIDS[@]} ; do
			FILE=${PIDS[$PID]}
			NAME=`basename $FILE`
			echo -n "Wait Job: "$PID" file " $NAME
			wait $PID
			RET=$?
			if [ $RET -eq 0 ] ; then
				echo " [OK]"
				cp "$FILE" "$SUCCESS_DIRECTORY"/$NAME
			else
				echo " [FAILED]"
				cp "$FILE" "$ERROR_DIRECTORY"/$NAME
			fi

			unset PIDS[$PID]
		done
	}

	echo "Load $# files and move them to $OUTPUT_DIRECTORY"

	while [ $# -gt 0 ] ; do
		FILE="$1"
		if [ -f "$FILE" ] ; then
			NAME=`basename $FILE`
			LOG_FILE="$LOG_DIR"/"$NAME"".log"
			echo "Processing $NAME "
			# Run your command with FILE here
			echo "$FILE" > "$LOG_FILE" 2>&1 &

			PID=$!
			
			PIDS[$PID]="$FILE"
			
			#wait $PID
			#RET=$?
			
			NBJOBS=`jobs -p | wc -l`
			if [ $NBJOBS -ge $MAX_PROCESSES ] ; then
				wait_jobs
			fi
			
		else
			echo $FILE" is not a file"
		fi

		if [ $# -eq 2 -a -d "$2" ] ; then
			#last arg is directory, skip it
			echo "Done"
			break
		fi

		shift
	done

	wait_jobs 
	

	exit 0
else
	echo "Sorry I need two arguments"
	exit 1
fi


