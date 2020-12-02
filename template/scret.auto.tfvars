# !!!!!IMPORTANT!!!!!! RENAME THIS FILE to secret.auto.tfvar
# so that .gitignore will ignore it.
# Once it has secrets in it that you never
# commit it or push to vc

eb_env_env_vars = {
  "MONGO_URI" = "<mongo url w user, password, etc.>"
  "GOOGLE_CLIENT_ID" = "<google client id>"
}
