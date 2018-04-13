# windup-openshift
## OpenShift image construction

1. Install Docker: `$ sudo dnf install docker`
1. Configure `docker` group (ref. [Manage Docker as a non-root user](https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user)):
   1. `$ sudo groupadd docker`
   1. `$ sudo usermod -aG docker $USER`
   1. Log out and log back in so that your group membership is re-evaluated
1. Test Docker is working: `$ docker run hello-world`
1. Sign up yourself to Docker Hub at https://hub.docker.com (the Docker ID is choose will be the `<your_docker_id>` value in the next steps)
1. Build this project: `mvn clean install -Ddocker.name.windup.web=docker.io/<your_docker_id>/windup-web-openshift -Ddocker.name.windup.web.executor=docker.io/<your_docker_id>/windup-web-openshift-messaging-executor`
1. Push images to docker hub:
   1. `$ docker login`
   1. `$ docker push docker.io/<your_docker_id>/windup-web-openshift`
   1. `$ docker push docker.io/<your_docker_id>/windup-web-openshift-messaging-executor`
   
## OpenShift image deployment

1. copy the raw content of file https://github.com/mrizzi/windup-openshift/blob/master/web/templates/web-template.json /windup-openshift/blob/master/web/templates/web-template.json
1. paste it in the "Import YAML / JSON" wizard in your Openshift installation
1. save and wait for the deployment to end

That's it!
