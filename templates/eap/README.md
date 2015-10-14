# application template for EAP
## my-eap6-ext-mysql-s2i.json

### How to use
This template sets parameters for connectiong MYSQL server. 
openshift-launcher.sh script modify standalone-openshift.xml based on parameters specified by this templates.

1.Create template
```
oc create -f my-eap6-ext-mysql-s2i.json
```
If you use this templates whole openshift environment, add `-n openshift`.

2.Create MySQL application
DATABASE_SERVICE_NAME is set ${APPLICATION_NAME}-mysql.

for example)
```
oc new-app --template mysql-ephemeral --param=DATABASE_SERVICE_NAME=eapapp-mysql --param=MYSQL_USER=dbuser --param=MYSQL_PASSWORD=dbpass --param=MYSQL_DATABASE=sampledb
```

3.Create Secret
```
create -f eap-app-secret.json
```
Original file is downloaded from https://github.com/jboss-openshift/application-templates/blob/master/secrets/eap-app-secret.json


4.Create EAP application.
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

### Note
`openshift-launcher.sh` is able to create two type of datasources. One is TX managed datasource, another is normal datasource.

The configuration of the datasources are primarily controlled by two environment variables, `TX_DATABASE_PREFIX_MAPPING` and `DB_SERVICE_PREFIX_MAPPING`.  These variables specify the prefixes that are used to identify the separate DB configurations, `DB_SERVICE_PREFIX_MAPPING` being a comma separated list (each will be configured) and `TX_DATABASE_PREFIX_MAPPING` being a single prefix (only one Object Store allowed).

 
#### DB_SERVICE_PREFIX_MAPPING
`DB_SERVICE_PREFIX_MAPPING='eapapp-mysql=MYDB'`

#### TX_DATABASE_PREFIX_MAPPING
`TX_DATABASE_PREFIX_MAPPING='eapapp-mysql=DB'`


### ISSUES
https://issues.jboss.org/browse/CLOUD-222
`DB_SERVICE_PREFIX_MAPPINGS` is able to include only one hyphen.



