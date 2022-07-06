kubectl create -f mysql-secret.yaml
kubectl create -f mysqlvolume.yaml
kubectl create -f mysql-deployment.yaml
kubectl create -f mysql_service.yaml