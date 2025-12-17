pipeline {
    agent any

    environment {
        // 1. Nombre de la imagen
        DOCKER_USER = 'emily06'
        IMAGE_NAME = 'proyecto1'
        IMAGE_TAG = 'ci'
        FULL_IMAGE = "${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
        DOCKERHUB_CREDS = credentials('dockerhub')
    }

    stages {
        stage('CI #1 - Build con Docker Compose') {
            steps {
                echo "Construyendo imagen: ${env.FULL_IMAGE}"
                // Construye la imagen usando el docker-compose.yml
                bat "docker-compose build"
            }
        }

        stage('CI #1 - Login a Docker Hub') {
            steps {
                echo "Autenticando en Docker Hub..."
                // Login usando las credenciales almacenadas
                bat "echo ${env.DOCKERHUB_CREDS_PSW} | docker login -u ${env.DOCKERHUB_CREDS_USR} --password-stdin"
            }
        }

        stage('CI #1 - Push a Docker Hub') {
            steps {
                echo "Publicando imagen: ${env.FULL_IMAGE}"
                bat "docker push ${env.FULL_IMAGE}"
            }
        }

        stage('CI #2 - Verificación de imagen') {
            steps {
                echo "Verificando imagen en Docker Hub..."
                // Esto realmente hace pull desde el registro remoto
                bat "docker pull ${env.FULL_IMAGE}"
                bat "docker images ${env.FULL_IMAGE}"
            }
        }

        stage('CI #2 - Ejecución de comandos') {
            steps {
                echo "Ejecutando comandos de revisión en el contenedor..."
                // Ejecuta comandos dentro de la imagen descargada
                bat """
                docker run --rm ${env.FULL_IMAGE} /bin/bash -lc \
                \"rpm --version && \
                 ruby --version && \
                 node --version && \
                 yarn --version && \
                 python --version\"
                """
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline ejecutado correctamente. Imagen ${env.FULL_IMAGE} publicada."
        }
        failure {
            echo "❌ Error en el pipeline."
        }
    }
}