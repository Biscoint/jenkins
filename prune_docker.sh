# jobs that build docker images bloat the host's disk.
# the command below erases all unused docker artifacts
# before you run this, make sure your necessary containers are running, specially jenkins!
docker system prune --all --volumes
