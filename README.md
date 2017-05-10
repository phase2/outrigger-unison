# Unison file sync

This container is used to synchronize local files with volumes in docker containers.
This greatly improves performance of file operations within containers when using Mac OSX
vs NFS mounts that are much slower handling many small files (such as node_modules, etc)

## Installation

Install these dependencies on your Mac:

* brew install unison
* brew install unox

## Project Setup

1. Modify your docker-composer.yml file to mount a named volume instead of using NFS.

The default name of the volume will be {ProjectName}-sync.

For example, if your docker-compose.yml contains the line:
```
  www:
    volumes:
      - .:/var/www
```
change it to
```
  www:
    volumes:
      - ProjectName-sync:/var/www
```

2. Add the following lines to the end of your docker-compose.yml file to define the named volume.
```
volumes:
  ProjectName-sync:
    external: true
```

## Usage

1. Start the unison container using the provided ``unison.sh`` script:
```
./unison.sh ProjectName
```
This will create the named docker volume, run a docker container for your unison server,
then start the local unison process to watch your local files.

The directory that you run the ``unison.sh`` script from is the directory that will
be synchronized with the mount point you specified in your project docker-compose.yml (/var/www in the above examle).

2. Start your project containers normally.
```
docker-compose up -d
```

Any changes to your local files will be synced into your docker containers.
Any changes to the files in your docker container mount point (/var/www) will be synced to your local Mac.
If there is a conflict, the file on your local machine is given preference.

A log file: ``ProjectName-sync.log`` is created in the directory where you ran ``unison.sh``
and will show any unison sync activity.

3. To stop sychronizing files, just stop the docker container:
```
docker stop ProjectName-sync
```
