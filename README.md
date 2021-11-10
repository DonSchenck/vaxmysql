To create the mariadb database:  

`kubectl apply -f mysql-secret.yaml`  
`kubectl apply -f mysqlvolume.yaml`  
`kubectl apply -f mysql-deployment.yaml` 
`kubectl apply -f mysql-service.yaml`   


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