#!/bin/sh
# Script to run unison sync container

PROJECT=apt
CONTAINER="${PROJECT}-sync"
VOLUME="${PROJECT}-sync"
LOGFILE="${PROJECT}-sync.log"
DNS="sync.${PROJECT}.vm"
PORT=5000

# Create the external volume
echo "Attaching sync volume ${VOLUME}..."
docker volume create --name=${VOLUME}

# Run the unison server in a container
echo "Waiting for unison container..."
CID=$(docker run --name ${CONTAINER} -it --rm -d \
  -v ${VOLUME}:/unison \
  --env UNISON_DIR=/unison \
  --label com.dnsdock.name=sync \
  --label com.dnsdock.image=${PROJECT} \
  my_unison)

# Wait for socker to become available
echo "Waiting for ${CONTAINER} container..."

while ! nc -z $DNS $PORT; do
  sleep 0.1 # wait for 1/10 of the second before check again
done

# Remove previous log
rm -f ${LOGFILE}
# Run the local unison process to connect to the container service
unison . socket://${DNS}:${PORT}/ \
  -auto -batch -silent -contactquietly \
  -repeat watch \
  -prefer . \
  -ignore "Name ${LOGFILE}" \
  -logfile ${LOGFILE} \
  >> /dev/null & \

echo "Starting initial sync.  Please wait..."
# Create a temp file to cause a sync action
touch ${LOGFILE}.tmp
# Initial sync is done when logfile has content
while [ ! -e ${LOGFILE} ]; do
  sleep 0.1 # wait for 1/10 of the second before check again
done
# Remove the temp file now that we are running
rm -f ${LOGFILE}.tmp

echo "${CONTAINER} ready and running in background."
echo "Use 'docker stop ${CONTAINER}' to stop."

