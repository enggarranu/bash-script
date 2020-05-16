#!/bin/bash
#declare variable
uname="er170218"

i=0
l=$(wc -l list_ip.txt | awk '{print $1}')

for ip in `cat list_ip.txt`
do 
    i=$((i+1))
    echo "proses ip $ip | ${i}/$((l+1))"

    #get clustername and postgres version
    lscluster_result=$(ssh $uname@$ip 'sudo su - postgres -c "pg_lsclusters"' | tail -1)
    postgres_version=$(echo $lscluster_result | awk '{print $1}')
    cluster_name=$(echo $lscluster_result | awk '{print $2}')
    config_path="/etc/postgresql/${postgres_version}/${cluster_name}/conf.d"
    
    ssh $uname@$ip "sudo su - postgres -c \"sed -i 's/none/ddl/g' ${config_path}/*.conf\""
    ssh $uname@$ip "sudo su - postgres -c \"pg_ctlcluster ${postgres_version} ${cluster_name} reload\""
    
    # result=$(ssh $uname@$ip "sudo su - postgres -c \"grep none ${config_path}/*.conf\"")
    # echo $result
    
    echo "---------"
done
