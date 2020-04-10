#!/bin/sh
set -x

# READ ME #
# First, create directory on /var/lib/postgresql/script/update_rpt/ before run
# End READ ME #

echo "db_product replication started at `date +"%c"`" > /var/lib/postgresql/script/update_rpt/ws_product_pic_tmp_status.txt
    min_id=`psql -d db_product -t -c "select coalesce(min(id),0) as min_id from only tb_product where id < 0;" | head -1 | xargs`
    while [ $min_id -ne 0 ]
    do
      max_id=$((min_id+500000))
      v_date=`psql -d db_product -t -c "select now();" | head -1 | xargs`
      echo $v_date
      echo "query started with min_id= $min_id and max_id= $max_id"
      psql -d db_product -t -c "WITH partition_data AS ( DELETE FROM ONLY public.tb_product WHERE id between $min_id and $max_id and id < 0 RETURNING product_id, description, file_name, thumb_name_1, thumb_name_2, x, y, status, create_by, create_time, update_by, update_time, file_name_wm, file_path, shop_id ) INSERT INTO public.tb_product (product_id, description, file_name, thumb_name_1, thumb_name_2, x, y, status, create_by, create_time, update_by, update_time, file_name_wm, file_path, shop_id) SELECT * FROM partition_data;"
      v_date=`psql -d db_product -t -c "select now();" | head -1 | xargs`
      echo "query finished with min_id= $min_id and max_id= $max_id"
      echo $v_date
      echo "sending to slack..."
      min_id=`psql -d db_product -t -c "select coalesce(min(id),0) as min_id from only tb_product where id < 0;" | head -1 | xargs`
      sh /var/lib/postgresql/script/status db_product tb_product $min_id
      echo ""
      echo "message sent to slack..."
      echo "sleep 1m..."
      sleep 30s
      echo "sleep done..."
      echo ""
      echo ""
    done
sh /var/lib/postgresql/script/status db_product tb_product script_finished_exit_0
echo "db_product replication completed at `date +"%c"`" >> /var/lib/postgresql/script/update_rpt/ws_product_pic_tmp_status.txt
