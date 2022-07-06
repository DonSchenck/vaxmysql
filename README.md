To create the mariadb database:  

`kubectl create -f mysql-secret.yaml`  
`kubectl create -f mysqlvolume.yaml`  
`kubectl create -f mysql-deployment.yaml`  
`oc new-app -e MYSQL_USER=mydemo -e MYSQL_PASSWORD=mydemo -e MYSQL_DATABASE=vaxdb registry.access.redhat.com/rhscl/mariadb-101-rhel7 --name mysql`  
`kubectl create -f mysql_service.yaml`   


To create the table "vaccination_summaries":  
PowerShell:  
`kubectl get pods`  
$podname="{mysql pod name from previous kubectl get pods command}"  

`kubectl cp ./create_database_vaxdb.sql ${podname}:/tmp/create_database_vaxdb.sql`  
`kubectl cp ./create_database.sh ${podname}:/tmp/create_database.sh`  
`kubectl exec deploy/mysql -- /bin/bash ./tmp/create_database.sh`  

`kubectl cp ./create_table_vaccination_summaries.sql ${podname}:/tmp/create_table_vaccination_summaries.sql`  
`kubectl cp ./create_tables.sh ${podname}:/tmp/create_tables.sh`  
`kubectl exec deploy/mysql -- /bin/bash ./tmp/create_tables.sh`  


Bash:  
`kubectl get pods`  
export PODNAME="{mysql pod name from previous kubectl get pods command}"  

`kubectl cp ./create_database_vaxdb.sql $PODNAME:/tmp/create_database_vaxdb.sql`  
`kubectl cp ./create_database.sh $PODNAME:/tmp/create_database.sh`  
`kubectl exec deploy/mysql -- /bin/bash ./tmp/create_database.sh`  

`kubectl cp ./create_table_vaccination_summaries.sql $PODNAME:/tmp/create_table_vaccination_summaries.sql`  
`kubectl cp ./create_tables.sh $PODNAME:/tmp/create_tables.sh`  
`kubectl exec deploy/mysql -- /bin/bash ./tmp/create_tables.sh`  

Expose service:  
`kubectl expose deploy/mysql --name mysql --port 3306 --type NodePort`

`GRANT ALL ON vaxdb.* to 'root'@'%' IDENTIFIED BY 'admin' WITH GRANT OPTION;`