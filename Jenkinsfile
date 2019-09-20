#!groovy
def branchName
pipeline {
	agent any
    environment {
        IntegrationTestPassed = 'false'
        IMAGE_NAME = 'webservice1'    
    }
    
	options {
		skipDefaultCheckout true
        timeout(time: 1, unit: 'HOURS')
        buildDiscarder(logRotator(numToKeepStr: '5'))
        timestamps()
    }
             
	stages {
	
		stage('Code checkout') {
			steps {
				deleteDir()
				checkout scm
				script {
					branchName = sh(returnStdout: true, script: 'git rev-parse --abbrev-ref HEAD').trim()
					echo branchName
				} 
			}
    	}	
	    stage('Build') {
	        steps {
	            sh '''
	        		mvn install:install-file -Dfile=lib/ojdbc7-12.1.0.jar -DgroupId=com.oracle -DartifactId=ojdbc7 -Dversion=12.1.0 -Dpackaging=jar
	            	mvn -B -Dskip.unit.tests=true clean package'''
	        }
	    }
	    
	    stage('Unit Test') { //on this stage New container will be created, but current pipeline workspace will be remounted to it automatically
	        steps {
	            sh 'mvn test' 
	            
		        emailext (
			      subject: "Unit test results: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
			      body: """<p>Unit test report for Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'</p>
			        <p>Check console output at "<a href="${env.BUILD_URL}">${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>"</p>""",
			      to: "siri.priya.pinninty@saic.com",
			      attachmentsPattern: '**/target/site/jacoco-ut/index.html'
			    )
	        }
	    }	
	    	    
	    stage('Integration Test') { 
	        steps {
	        
	        	sh'rm -f cucumber.zip'
	            sh 'mvn verify -Dskip.unit.tests=true' 
	            script {
	            	IntegrationTestPassed = 'true'
	            }
	           // zip dir: 'target/reports/cucumber/html', glob: '', zipFile: 'cucumber.zip'
		        emailext (
			      subject: "Integration test results: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
			      body: """<p>Integration test report for Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'</p>
			        <p>Check console output at "<a href="${env.BUILD_URL}">${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>"</p>""",
			      to: "siri.priya.pinninty@saic.com",
			   //   attachmentsPattern: 'cucumber.zip'
			    )
	        }
	    }
	    
 	    stage ('Docker Build') {    
	        steps {
				sh 'sudo docker build --no-cache -t $IMAGE_NAME:dev$BUILD_NUMBER .'
	        }
	    }
	    
	     stage("Docker push") {
	
        	steps {
        		script {
					
				    sh '''
				    chmod 755 docker-push-wrapper.sh
					sudo ./docker-push-wrapper.sh \
						--image-name "$IMAGE_NAME" \
						--tag-name "dev$BUILD_NUMBER"
					sudo docker rmi $IMAGE_NAME:dev$BUILD_NUMBER'''	

				}
        	}
        }
        
        stage("Dev deploy") {
       
        	steps {
        		script {
					
					sh '''
						aws cloudformation deploy --template-file webservice1-service.yaml \
						--parameters \
						"ParameterKey=ContainerName,ParameterValue=$IMAGE_NAME" \
						"ParameterKey=ServiceName,ParameterValue=$IMAGE_NAME" \
						"ParameterKey=ContainerTag,ParameterValue=$BUILD_NUMBER" \
                    --stack-name "webservice1" \
                    --region us-east-1
					'''
				}
        	}
        }	        
	}
	
     post {
     
        always {
	      sh '''rm -rf build/workspace'''
	      echo 'IntegrationTestPassed = ' + IntegrationTestPassed
          script {
            if (IntegrationTestPassed == 'false') {
            	echo 'Inside false'
            	sh 'mvn -Ddocker.host=unix:///var/run/docker.sock  -Pdocker docker:stop'
            }
    	  }
	    }
     		success {
     		  emailext (
		      subject: "Build SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
		      body: """<p>The build Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' is successful.</p>
		        <p>Check console output at "<a href="${env.BUILD_URL}">${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>"</p>""",
		      to: "siri.priya.pinninty@saic.com"
		    )
     	}  
			unstable {
     		  emailext (
		      subject: "Build UNSTABLE: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
		      body: """<p>The build Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' is unstable.</p>
		        <p>Check console output at "<a href="${env.BUILD_URL}">${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>"</p>""",
		      to: "siri.priya.pinninty@saic.com"
		    )
     	} 
			failure {
     		  emailext (
		      subject: "Build FAILURE: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
		      body: """<p>The build Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' has failed.</p>
		        <p>Check console output at "<a href="${env.BUILD_URL}">${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>"</p>""",
		      to: "siri.priya.pinninty@saic.com"
		    )
     	} 
 	}  
}
