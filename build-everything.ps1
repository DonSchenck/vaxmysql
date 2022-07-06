Write-Output "Copying create_database_vaxdb.sql to pod"
kubectl cp ./create_database_vaxdb.sql ${podname}:/tmp/create_database_vaxdb.sql

Write-Output "Copying create_database.sh to pod"
kubectl cp ./create_database.sh ${podname}:/tmp/create_database.sh

Write-Output "Executing create_database.sh in pod"
kubectl exec deploy/mysql -- /bin/bash ./tmp/create_database.sh

Write-Output "Copying create_table_vaccination_summaries.sql to pod"
kubectl cp ./create_table_vaccination_summaries.sql ${podname}:/tmp/create_table_vaccination_summaries.sql

Write-Output "Copying create_tables.sh to pod"
kubectl cp ./create_tables.sh ${podname}:/tmp/create_tables.sh

Write-Output "Executing create_tables.sh in pod"
kubectl exec deploy/mysql -- /bin/bash ./tmp/create_tables.sh