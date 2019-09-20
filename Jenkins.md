#Get blue ocean docker image.
docker pull jenkinsci/blueocean

#run the image
docker run -u root --rm -d -p 8080:8080 -p 50000:50000 -v jenkins-data:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkinsci/blueocean

#When configuring jenkins for the first time, unlock jenkins and create admin user.
install all recomonded plugins
install Pipeline Utility steps pligin
restart the jenkins

Create pipeline for safer persist service with SCM as SVN repository and create a jenkins credentials for you SVN repo access and use them while creation of pipeline.


#For testing the email notifications pull the below docker image
docker pull djfarrelly/maildev

#run the smtp server container on local
docker run -p 1080:80 -p 1025:25 djfarrelly/maildev

#Start the mail client on browser
http://localhost:1080

On Jenkins configure mailext plugin with smtp server details

Then Build the pipeline.
