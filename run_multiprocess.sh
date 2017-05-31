if [ $# -lt 3 ] ; then
    echo "Usage: $0 [REPEAT] [PROCESSES] [CMD]"
    exit
fi

REPEAT=${1}
MAX_PROCESSES=${2}
CMD=${3}

declare -a PIDS

wait_jobs ()
{
    for PID in ${!PIDS[@]} ; do
        CMD="${PIDS[$PID]}"
        echo -n "Wait Job: "$PID" CMD " $CMD
        wait $PID
        RET=$?
        if [ $RET -eq 0 ] ; then
            echo " [OK]"
        else
            echo " [FAILED]"
        fi

        unset PIDS[$PID]
        # only wait for one job at a time
        break
    done
}



for X in `seq 1 $REPEAT`; do
    echo "Processing $CMD "
    # Run your command here
    time $CMD >/dev/null &

    PID=$!

    PIDS[$PID]="$CMD"
    

    #wait $PID
    #RET=$?

    # Pause if necessary, to avoid running more than MAX_PROCESSES
    
    while [ `jobs -p | wc -l` -ge $MAX_PROCESSES ] ; do
        wait_jobs
    done
done
    
# finish by waiting for all jobs to end
wait_jobs 


exit 0
