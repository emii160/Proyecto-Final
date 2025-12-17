pipeline {
    agent any

    environment {
        IMAGE_NAME = "alma8-full"
        IMAGE_TAG  = "proyecto-final"
        DOCKERHUB_USER = "yeyo19"
        DOCKERHUB_REPO = "${DOCKERHUB_USER}/${IMAGE_NAME}"
        CONTAINER_NAME = "alma8_revision"
    }

    stages {

        /*CI #1: BUILD + PUSH*/

        stage('Clonar repositorio') {
            steps {
                echo "Clonando repositorio"
                checkout scm
            }
        }

        stage('Construir imagen Docker') {
            steps {
                echo "Construyendo imagen con Docker Compose"
                bat 'docker compose build full'
            }
        }

        stage('Etiquetar imagen') {
            steps {
                echo "Etiquetando imagen"
                bat """
                    docker tag alma8-full:1.0 %DOCKERHUB_REPO%:%IMAGE_TAG%
                """
            }
        }

        stage('Subir imagen a Docker Hub') {
            steps {
                echo "Subiendo imagen a Docker Hub"
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    bat """
                        echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
                        docker push %DOCKERHUB_REPO%:%IMAGE_TAG%
                    """
                }
            }
        }

        /*CI #2: PULL + VALIDACIÓN*/

        stage('Descargar imagen desde Docker Hub') {
            steps {
                bat 'docker pull %DOCKERHUB_REPO%:%IMAGE_TAG%'
            }
        }

        stage('Eliminar contenedor previo') {
            steps {
                bat 'docker rm -f %CONTAINER_NAME% || exit 0'
            }
        }

        stage('Ejecutar contenedor') {
            steps {
                bat """
                    docker run -d --name %CONTAINER_NAME% %DOCKERHUB_REPO%:%IMAGE_TAG% tail -f /dev/null
                """
            }
        }

        stage('Verificar versión de RPM') {
            steps {
                bat 'docker exec %CONTAINER_NAME% rpmbuild --version'
            }
        }

        stage('Verificar versión de Ruby') {
            steps {
                bat 'docker exec %CONTAINER_NAME% ruby -v'
            }
        }

        stage('Verificar versiones de Node.js') {
            steps {
                bat 'docker exec %CONTAINER_NAME% bash -lc "node -v"'
                bat 'docker exec %CONTAINER_NAME% bash -lc "npm -v"'
                bat 'docker exec %CONTAINER_NAME% bash -lc "yarn -v"'
            }
        }

        stage('Verificar versión de Python') {
            steps {
                bat 'docker exec %CONTAINER_NAME% python --version'
            }
        }

        stage('Hola Mundo desde Python') {
            steps {
                bat 'docker exec %CONTAINER_NAME% python -c "print(\'Hola Mundo\')"'
            }
        }
    }

    post {
        always {
            bat 'docker rm -f %CONTAINER_NAME% || exit 0'
        }
        success {
            echo "Pipeline ejecutado correctamente"
        }
        failure {
            echo "Error en el pipeline"
        }
    }
}