import groovy.json.*

def openshiftTemplate = new File(this.args[0])
def jsonSlurper = new JsonSlurper().parseText(openshiftTemplate.text)
def parameter = jsonSlurper.parameters.find { it.name == "DOCKER_IMAGES_TAG" }
parameter.value = this.args[1]
openshiftTemplate.write(new JsonBuilder(jsonSlurper).toPrettyString())

