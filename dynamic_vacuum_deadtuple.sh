#!/bin/bash
# dynamic_vacuum created by enggar.hariawan@tokopoedia.com

starttime=1731
endtime=0400

# initialize variable
datname=$1
timestamp=$(date +%F_%T)
sqlPath="/tmp/dynamic_vacuum"
prefixName="dynamic_vacuum_deadtuple_${timestamp}"
posfixSql="sql"
postfixLog="log"
masterLog="${sqlPath}/dynamic_vacuum_deadtuple_master.${postfixLog}"
echo "Program Start at ${timestamp}" >> ${masterLog}

while true
do
    currenttime=$(date +%k%M)
    if [ $currenttime -ge $starttime ] && [ $currenttime -le $endtime ]; then
        timestamp=$(date +%F_%T)
        prefixName="dynamic_vacuum_deadtuple_${timestamp}"
        echo "Program Start at ${timestamp}" >> ${sqlPath}/${prefixName}.${postfixLog}
        
        #create directory on tmp
        mkdir -p ${sqlPath}

        # generate sql command
        psql -d ${datname} -t -c "select 'vacuum (freeze, analyze, verbose) ' || schemaname || '.'|| relname || ';' FROM pg_stat_user_tables where schemaname = 'public' and n_live_tup > 0 and n_dead_tup > 0 order by ((case when n_dead_tup = 0 then 1 else n_dead_tup end)::float  / (case when n_live_tup = 0 then 1 else n_live_tup end)::float)*100 desc limit 5" > ${sqlPath}/${prefixName}.${posfixSql}

        echo "executing ${sqlPath}/${prefixName}.${posfixSql}" >> ${masterLog}

        # run sql command
        psql -d ${datname} -f ${sqlPath}/${prefixName}.${posfixSql} >> ${sqlPath}/${prefixName}.${postfixLog}

        echo "Program finish at $(date +%F_%T)" >> ${sqlPath}/${prefixName}.${postfixLog}
    else
        echo "program running diluar jadwal" 
        echo "program running diluar jadwal" >> ${masterLog}
        break
    fi
done
echo "Program Finish at ${timestamp}" >> ${masterLog}
