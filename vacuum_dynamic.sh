#!/bin/bash
# dynamic_vacuum created by enggar.hariawan@tokopoedia.com

starttime=1731
endtime=2000

# initialize variable
datname=$1
timestamp=$(date +%F_%T)
sqlPath="/tmp/dynamic_vacuum"
prefixName="dynamic_vacuum_${timestamp}"
posfixSql="sql"
postfixLog="log"
masterLog="${sqlPath}/dynamic_vacuum_master.${postfixLog}"
echo "Program Start at ${timestamp}" >> ${masterLog}

while true
do
    currenttime=$(date +%k%M)
    if [ $currenttime -ge $starttime ] && [ $currenttime -le $endtime ]; then
        timestamp=$(date +%F_%T)
        prefixName="dynamic_vacuum_${timestamp}"
        echo "Program Start at ${timestamp}" >> ${sqlPath}/${prefixName}.${postfixLog}
        
        #create directory on tmp
        mkdir -p ${sqlPath}

        # generate sql command
        psql -d ${datname} -t -c "select 'vacuum (freeze, analyze, verbose) ' || oid::regclass || ';' from pg_class where relkind in ('r', 't', 'm') order by age(relfrozenxid) desc limit 5" > ${sqlPath}/${prefixName}.${posfixSql}

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
