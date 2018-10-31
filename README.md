# windup-openshift: Red Hat Application Migration Toolkit on OpenShift
This project is useful if you want to try RHAMT on an OpenShift instance.  
If you just want to test RHAMT using the [images](https://hub.docker.com/u/windup3/) we have made available in the docker.io repository, go straight to the [OpenShift template deployment](#openshift-template-deployment) section.  
If you have made some changes to RHAMT and you want to test them on an OpenShift instance, in the next paragraph you'll find all the information for building your own docker images so that you're free to test your code.  
There's also the case that you don't have an OpenShift instance available and, in this scenario, Red Hat Container Development Kit can help you working locally on your machine with any need for an OpenShift instance to test your changes to the code. In this case please follow the instructions in the [Working with Red Hat Container Development Kit](#working-with-red-hat-container-development-kit) section.

## OpenShift image construction
### Install Docker
For building this project and creating Docker images you have to have a Docker instance running locally on your machine so that you can pull the built images.  
Next you'll find some basic instructions to install Docker based on your local OS.
#### Install Docker for Fedora
1. Install Docker: `$ sudo dnf install docker`
1. Configure `docker` group (ref. [Manage Docker as a non-root user](https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user)):
   1. `$ sudo groupadd docker`
   1. `$ sudo usermod -aG docker $USER`
   1. Log out and log back in so that your group membership is re-evaluated
1. Test Docker is working: `$ docker run hello-world`

For any issue related to installation, you can refer to [Docker documentation](https://docs.docker.com/install/linux/docker-ce/fedora/).
#### Install Docker for other OS
For any other platform you can follow the detailed instructions provided in the [Install Docker](https://docs.docker.com/install/) guide from Docker.
### Create an account to Docker Hub
You need an account on https://hub.docker.com in order to push your images and have them available in the [docker.io repository](https://docs.openshift.org/latest/architecture/core_concepts/builds_and_image_streams.html#important-terms).  
So sign up yourself to Docker Hub at https://hub.docker.com taking care that the Docker ID you choose will be the `<your_docker_id>` value in the next steps.
### Create Docker images
1. Build this project: `$ mvn clean install -Ddocker.name.windup.web=<your_docker_id>/windup-web-openshift -Ddocker.name.windup.web.executor=<your_docker_id>/windup-web-openshift-messaging-executor`
1. Push images to docker hub:
   1. `$ docker login`
   1. `$ docker push <your_docker_id>/windup-web-openshift`
   1. `$ docker push <your_docker_id>/windup-web-openshift-messaging-executor`

If you want you can also set the tag for the built images (e.g. if you are working on a specific branch and you want to create images tagged with the branch name), you just have to add the tag name to the `docker.name.windup.web` and `docker.name.windup.web.executor` system properties' values (i.e. from the above example `-Ddocker.name.windup.web=<your_docker_id>/windup-web-openshift:tag_value -Ddocker.name.windup.web.executor=<your_docker_id>/windup-web-openshift-messaging-executor:tag_value`)

### Point to your images
Now that your images are available on docker.io repository, you have to reference them in RHAMT template in order to use these images in the deployments.
1. open [`./templates/src/main/resources/web-template.json`](templates/src/main/resources/web-template.json) in an IDE or text editor
1. change all the `"image"` values to point to `docker.io/<your_docker_id>/` instead of `docker.io/windup3/`
   
## OpenShift template deployment
There are two different ways for deploying RHAMT on OpenShift based upon if you have [`cluster-admin privileges`](https://docs.openshift.org/latest/architecture/additional_concepts/authorization.html#roles): if you have those privileges you can decide to follow [Template deployment in OpenShift catalog](#template-deployment-in-openshift-catalog) (because you can operate on the default `openshift` project) or [Import template in Openshift Web Console](#import-template-in-openshift-web-console) otherwise you can just go with the latter approach ([Import template in Openshift Web Console](#import-template-in-openshift-web-console))

### Template deployment in OpenShift catalog
1. login to Openshift: `$ oc login`
1. create the template: `$ oc create -f ./templates/src/main/resources/web-template.json -n openshift`

Now, if you go to OpenShift Web Console home page, you'll see the Red Hat Application Migration Toolkit (ref. *screenshot-0*) in the list of the available templates and so you can deploy it to a project just like any other template.

![screenshot-0](https://user-images.githubusercontent.com/7288588/38804671-80e5af28-4173-11e8-979c-58dc84e2371f.png)
*screenshot-0: in OpenShift Web Console (v3.7) `Browse Catalog` page you can see the `Red Hat Application Migration Toolkit 4.1` icon (4th row, 2nd column)*
### Import template in Openshift Web Console
1. copy the raw content of file [web-template.json](templates/src/main/resources//web-template.json)
1. paste it in the "Import YAML / JSON" wizard in Openshift Web Console (ref. *screenshot-1*)
1. save and wait for the deployment to end

![screenshot-1](https://user-images.githubusercontent.com/7288588/38807819-273b0f1c-417e-11e8-96d2-c82b41ee59bf.png)
*screenshot-1: in OpenShift Web Console (v3.7) `Import YAML / JSON` wizard you can paste template raw content*
## Working with Red Hat Container Development Kit
If you want to build locally your own images without the need to push them to the Docker repository, you can use Red Hat Container Development Kit (CDK).  
"Red Hat Container Development Kit provides a pre-built Container Development Environment based on Red Hat Enterprise Linux to help you develop container-based applications quickly." (ref.  [Red Hat Container Development Kit documentation](https://developers.redhat.com/products/cdk/overview/)).  
For installing CDK, please refer to the https://developers.redhat.com web site where you can find the [Hello World!](https://developers.redhat.com/products/cdk/hello-world/) guide.  
Once you have a fully working CDK instance, you can follow the next steps:

1. [_optional_]`$ systemctl stop docker` (do this only if you have Docker running on your machine)
1. `$ minishift docker-env` to display the command you need to type into your shell in order to configure your Docker client since the command output will differ depending on OS and shell type
1. execute the command from the step before
1. `$ docker ps` to test that it's working fine and you can see in output a list of running containers
1. `$ oc login -u developer -p whatever` to login to CDK OpenShift (the `-p` password parameter can really be whatever value you want for the `developer` pre-built user in the CDK)
1. `$ docker login -u developer -p $(oc whoami -t) $(minishift openshift registry)` to log into the CDK OpenShift Docker registry
1. `$ mvn clean install -Ddocker.name.windup.web=$(minishift openshift registry)/$(oc project -q)/windup-web-openshift:latest -Ddocker.name.windup.web.executor=$(minishift openshift registry)/$(oc project -q)/windup-web-openshift-messaging-executor:latest` to build the Docker images for this project with the right tags to push them to CDK OpenShift Docker registry
1. `$ docker push $(minishift openshift registry)/$(oc project -q)/windup-web-openshift` to push the image to the registry to create an image stream 
1. `$ docker push $(minishift openshift registry)/$(oc project -q)/windup-web-openshift-messaging-executor` to push the image to the registry to create an image stream 
1. now, before proceeding, you have to follow the above instructions about [OpenShift template deployment](#openshift-template-deployment)
1. once you have successufully deployed, you can change the deployments to point to your local images.  
Go to `Deployments` web page and:
   1. choose `rhamt-web-console` deployment page
   1. select `Actions` => `Edit` from the top right button (ref.)
   ![screenshot_action_edit](https://user-images.githubusercontent.com/7288588/39518963-2cfb1030-4e05-11e8-9c6b-a8d071d4fc3b.png)
   1. check the `Deploy images from an image stream tag` box and select the values for the `Image Stream Tag` comboboxes selecting your project's name as `Namespace`, `windup-web-openshift` for `Image Stream` and `latest` for `Tag`
   ![screenshot_imagestream](https://user-images.githubusercontent.com/7288588/39518990-49f385fa-4e05-11e8-9a80-d04992f90f0c.png)
   1. push the `Save` button at the bottom of the page
   1. repeat these steps for `rhamt-web-console-executor` deployment using `windup-web-openshift-messaging-executor` as `Image Stream` combox value
   
Now your deployments are using the Docker images you have built locally on your machine and, whenever you update these images, new deployments will be triggered automatically when `docker push` command executes.

If you need more informations about how to interact with the CDK OpenShift Docker registry, please refer to the [Accessing the OpenShift Docker Registry](https://docs.openshift.org/latest/minishift/openshift/openshift-docker-registry.html) guide.
