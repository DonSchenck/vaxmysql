kubectl create -f mariadb-secret.yaml
kubectl create -f mariadb-pvc.yaml
kubectl create -f mariadb-deployment.yaml
kubectl create -f mariadb-service.yaml