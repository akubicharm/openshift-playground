# application template for EAP
## my-eap6-ext-mysql-s2i.json

### How to use
This template sets parameters for connectiong MYSQL server. 
openshift-launcher.sh script modify standalone-openshift.xml based on parameters specified by this templates.

1. Create template
```
oc create -f my-eap6-ext-mysql-s2i.json
```
If you use this templates whole openshift environment, add `-n openshift`.

2. Create MySQL application
DATABASE_SERVICE_NAME is set ${APPLICATION_NAME}-mysql.

for example)
```
oc new-app --template mysql-ephemeral --param=DATABASE_SERVICE_NAME=eap-app-mysql --param=MYSQL_USER=dbuser --param=MYSQL_PASSWORD=dbpass --param=MYSQL_DATABASE=sampledb
```

2. Create EAP application.
```
oc new-app --template=my-eap6-ext-mysql-s2i \
--param=SOURCE_REPOSITORY_URL=<YOUR GIT REPOSITORY>
--param=SOURCE_REPOSITORY_REF=<YOUR RIPOSITORY REFS> \
--param=DB_DATABASE=sampledb \
--param=DB_USERNAME=dbuser \
--param=DB_PASSWORD=dbpass
```

DB_DATABASE is same as MYSQL_DATABASE
DB_USERNAME is same as MYSQL_USER
DB_PASSWORD is same as MYSQL_PASSWORD

