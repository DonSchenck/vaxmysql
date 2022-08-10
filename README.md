To create the mariadb database:  

`kubectl create -f mysql-secret.yaml`  
`kubectl create -f mysqlvolume.yaml`  
`kubectl create -f mysql-deployment.yaml`  
`oc new-app -e MYSQL_USER=mydemo -e MYSQL_PASSWORD=mydemo -e MYSQL_DATABASE=vaxdb registry.access.redhat.com/rhscl/mariadb-101-rhel7 --name mysql`  
`kubectl create -f mysql_service.yaml`   


To create the table "vaccination_summaries":  
PowerShell:  
`kubectl get pods`  
Use the output from this command to set the environment variable "$PODNAME".  

`$PODNAME="{mysql pod name from previous kubectl get pods command}"`  

`kubectl cp ./create_database_vaxdb.sql ${PODNAME}:/tmp/create_database_vaxdb.sql`  
`kubectl cp ./create_database.sh ${PODNAME}:/tmp/create_database.sh`  
`kubectl exec deploy/mysql -- /bin/bash ./tmp/create_database.sh`  

`kubectl cp ./create_table_vaccination_summaries.sql ${PODNAME}:/tmp/create_table_vaccination_summaries.sql`  
`kubectl cp ./create_tables.sh ${PODNAME}:/tmp/create_tables.sh`  
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
`kubectl expose deploy/mariadb --name mariadb --port 3306 --type NodePort`

`GRANT ALL ON vaxdb.* to 'root'@'%' IDENTIFIED BY 'admin' WITH GRANT OPTION;`
# vac-seen-mariadb

## What is this?  
This workshop/activity/tutorial will guide you through the creation of a MariaDB database that is used by the ["vac-seen system" C# and Kakfa activity](https://developers.redhat.com/developer-sandbox/activities) associated with the [Developer Sandbox for Red Hat OpenShift](https://developers.redhat.com/developer-sandbox).  

At the end of this tutorial you will have an instance of a MariaDB database running in your OpenShift cluster with the necessary database and table created.  

Even if you don't follow the activity associated with this repository, the code and instructions here can be a basis for your efforts to create a MariaDB instance in your Kubernetes or OpenShift cluster.  

## Prerequisites  
The following **three** prerequisites are necessary:  
1. An account in [Developer Sandbox for Red Hat OpenShift](https://developers.redhat.com/developer-sandbox) (No problem; it's free). This is not actually *necessary*, since you can use this tutorial with any OpenShift cluster *as long as the Service Binding Operator is installed* (it's install in the Developer Sandbox).  If you don't have access to a cluster with the Service Binding Operator, or just want to experiment on your own, the Developer Sandbox is perfect.  
1. The `oc` command-line tool for OpenShift. There are instructions later in this article for the installation of `oc`.  
2. The `kubectl` command-line tool for Kubernetes. There are instructions later in this article for the installation of `kubectl`.  

## All Operating Systems Welcome  
You can use this activity regardless of whether your PC runs Windows, Linux, or macOS.  

## High-level overview 
Here's what you'll be doing:
1. Creating the Secret object used to access to database.  
1. Creating a Persistent Volume Claim to store the database.  
1. Creating an instance of a MariaDB database in your cluster.  
1. Creating a Service inside your cluster to allow your database to be used by other applications.  
1. Copying scripts to create the database "vaxdb" in the MariaDB instance.  
1. Copying scripts to create the table "vaccination_summaries" in the database.  
1. Executing the scripts.  


## Step 0: Prepare the prerequisites
### 0.1 Get your sandbox
The [Developer Sandbox for Red Hat OpenShift](https://developers.redhat.com/developer-sandbox) is a free offering from Red Hat that gives you developer-level access rights to an OpenShift cluster. If you have not already signed up for this free cluster, do so by visiting [the Developer Sandbox web page](https://developers.redhat.com/developer-sandbox). It's free and requires only an email address and password; no credit card necessary.  

If you are using your own cluster, [the Service Binding Operator must be installed](https://docs.openshift.com/container-platform/4.9/applications/connecting_applications_to_services/installing-sbo.html).  

### 0.2 Install the 'oc' CLI  
The `oc` command line interface (CLI) allows you to work with your OpenShift cluster from a terminal command line. The `oc` CLI for OpenShift can be installed by following the instructions on [the oc CLI Getting Started web page](https://docs.openshift.com/container-platform/4.9/cli_reference/openshift_cli/getting-started-cli.html).

### 0.3 Install the 'kubectl' CLI  
This `kubectl` CLI allows you to work with a Kubernetes cluster from a terminal command line. The `kubectl` CLI can be installed by following the instructions on [the kubectl installation page](https://kubernetes.io/docs/tasks/tools/).  

### 0.3 Log in to your sandbox from the command line
Open a terminal session on your local machine and use the `oc login` command to log into your cluster from there. The instructions for doing that are in [this short article](https://developers.redhat.com/blog/2021/04/21/access-your-developer-sandbox-for-red-hat-openshift-from-the-command-line).  This can be done using macOS, Windows, and Linux.

## 1. Creating the Secret object used to access to database  

When the database instance is being created, we have the opportunity to specify a root password. This password is stored in a Kubernetes Secret object, which we are calling "mariadbpassword". The password is created by taking the password ("admin" in this case) and Base64-encoding it. The resulting string is then put into the YAML file for the secret. In this case, the YAML file is called "mariadb-secret.yaml".

This has already been done, as we can see in the contents of the file "mariadb-secret.yaml":

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mariadbpassword
type: Opaque
data:
  password: YWRtaW4=
```

Note: You don't need to do this, but the bash command to Base64-encode the string looks like the following:  

`echo "admin" | base64`

For PowerShell, you would use the following:  

```powershell
$p = 'admin'
$b = [System.Text.Encoding]::ASCII.GetBytes($p)
$e =[Convert]::ToBase64String($b)
"Encoded password ($p) is: $e"
```

Given that we have the correct YAML, create the secret by running the following command:  
___
<h2>RUN THIS COMMAND:</h2>  

`oc create -f mariadb-secret.yaml`
___  

## 2. Creating a Persistent Volume Claim to store the database  
Before we can create the database, we need a file system for the files related to the MariaDB instance. You *could* choose to use an ephemeral instance of MariaDB, but in that case the data would be destroyed when the pod running the instance is stopped. We want the data to persist, so we need a Persistent Volume Claim (PVC).

Here's the content of the YAML file that creates the PVC:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mariadbvolume
spec:
  resources:
    requests:
      storage: 5Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
```
You can see that we are requesting a 5GB section of block storage, akin to a 5GB hard drive. The name, which as assigned by us, is used later by the Deployment object which creates the MariaDB instance.

<h2>DO THIS:</h2>  

`oc create -f mariadb-pvc.yaml`  

## 3. Creating an instance of a MariaDB database in your cluster  
Now that we have the secret and PVC we need, we can go ahead and create the MariaDB instance. Here is the content of the YAML file that creates the MariaDB instance:  
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mariadb
spec:
  selector:
    matchLabels:
      app: mariadb
      tier: database
  template:
    metadata:
      labels:
        app: mariadb
        tier: database
    spec:
      containers:
      - name: mariadb
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mariadbpassword
              key: password
        image: mariadb
        resources:
          limits:
            memory: "512Mi"
            cpu: "500m"
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mariadbvolume
          mountPath: /var/lib/mysql
      volumes:
       - name: mariadbvolume
         persistentVolumeClaim:
           claimName: mariadbvolume
```
It's time to create the MariaDB instance.

<h2>DO THIS:</h2>  

`oc create -f mariadb-deployment.yaml`  

When this finishes, you will have a MariaDB instance running in your OpenShift cluster. We have not created a database, nor have we created any tables. But the database is up and running. You can prove this by using the following command (as an example):


## 4. Creating a Service inside your cluster to allow your database to be used by other applications  
We need a Service object which allows applications to use the MariaDB instance. I've named the object "mariadb", but the name *does not* need to match the application.

Here's the YAML file, "mariadb-service.yaml", that creates the service:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: mariadb
spec:
  selector:
    app: mariadb
  ports:
    - protocol: TCP
      port: 3306
      targetPort: 3306
```
<h2>DO THIS:</h2>  

`oc create -f mariadb-service.yaml`  

Now, any application can refer to the data by the service name, "mariadb". Here's an example of that in an environment variable connection string:  

```bash
MYSQL_CONNECTION_STRING="Server=mariadb;User ID=root;Password={admin_password};Database=vaxdb;"
```



## 5. Copying scripts to create the database "vaxdb" in the MariaDB instance  

To create the table "vaccination_summaries":  
PowerShell:  
`kubectl get pods`  
$podname="{mysql pod name from previous kubectl get pods command}"  

`kubectl cp ./create_database_vaxdb.sql ${podname}:/tmp/create_database_vaxdb.sql`  
`kubectl cp ./create_database.sh ${podname}:/tmp/create_database.sh`  
`kubectl exec deploy/mysql -- /bin/bash ./tmp/create_database.sh`  

## 6. Copying scripts to create the table "vaccination_summaries" in the database  
 
## 7. Executing the scripts  

## Congratulations
You have a MariaDB database instance running in OpenShift.
