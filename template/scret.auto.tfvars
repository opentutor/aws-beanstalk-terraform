# !!!!!IMPORTANT!!!!!! RENAME THIS FILE to secret.auto.tfvar
# so that .gitignore will ignore it.
# Once it has secrets in it that you never
# commit it or push to vc

secret_api_secret = "<arbitrary api secret used to elevate privileges for inter-service graphql requests>"
secret_jwt_secret = "<arbitrary secret used to encode/decode jwt tokens"
secret_mongo_uri = "<mongo url w user, password, etc.>"
