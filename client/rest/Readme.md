# How To Use REST API

## Start Build

```
curl -i -v -H  "Accept: application/json" \
-H "X-HTTP-Method-Override: PUT" -X POST -k \
-d start-build.json \
https://master.cloud:8443/oapi/v1/namespaces/test/buildconfigs/hello-ose/webhooks/4dee0fcb4de85bc6/generic
```
