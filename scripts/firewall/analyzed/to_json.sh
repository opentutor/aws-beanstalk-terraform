#!/bin/bash
echo '[' > uncompressed-v2.json
for i in `find ../logs-v2/2022 -name *gz -print`
do
    gzip -cd $i | tr '\n' ',' >> uncompressed-v2.json
done
# to make json valid we need another element after the last comma:
echo '{}]' >> uncompressed-v2.json


echo '[' > uncompressed-cf.json
for i in `find ../logs-cf/2022 -name *gz -print`
do
    gzip -cd $i | tr '\n' ',' >> uncompressed-cf.json
done
# to make json valid we need another element after the last comma:
echo '{}]' >> uncompressed-cf.json
