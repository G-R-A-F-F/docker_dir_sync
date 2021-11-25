mkdir /tmp/A
mkdir /tmp/B

docker run --rm --name dir_sync \
 -v "/tmp/A":"/sync/data/A" \
 -v "/tmp/B":"/sync/data/B" \
 sfilabs/dir_sync:latest

# docker run --rm --name dir_sync \
#  -v "/tmp/A":"/sync/data/A" \
#  -v "/tmp/B":"/sync/data/B" \
#  -e RSYNC_DELETE=false \
#  sfilabs/dir_sync:latest