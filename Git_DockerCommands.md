
git remote add safer-persist-service-git ./.git
git push --set-upstream safer-persist-service-git master
cd c:\temp
git clone C:\Indranil\Work\FMCSA\safer\springBootWkspc\FMCSA_NEW_SAFER_SVN\safer-persist-service\.git

--------------------------- Docker --------------------------------
mvn clean package
docker container ls

docker run --net safernet --rm --name safernet-unzip-service -p 8091:8091 safer-unzip-service  
#docker run --network safernet --name safernet-unzip
#docker run -p 8091:8091 safer-unzip-service --network safernet

--------------------------- Docker --------------------------------


# Old command  do not use 
#docker run -p 8090:8090 safer-upload-service --network safernet
# docker inspect safer-upload-service | grep '"IPAddress"' | head -n 1

#######################################################################
################ One time activities ####################
########Create saferNet to call other service in the same network
#docker network create safernet
#docker run --network safernet --name safernet-upload

########Create volume to share files 

#docker volume create SaferUploadVolume

#docker volume inspect SaferUploadVolume

################End One time activities ####################
########################################################################


mvn clean package

docker build -t safer-persist-service  .


docker run --net safernet --rm --name safer-persist-service -v SaferUploadVolume:/safer-new -p 8092:8092 safer-persist-service
docker container ps -a


docker exec -it <Container Id>   /bin/ash 


#copy from host (local file) to container - One time activity
cd C:\Indranil\Work\FMCSA\safer\springBootWkspc\FMCSA_NEW_SAFER_SVN

docker cp ./uploads <container id>:/safer-new

###########Overall some docker commands





