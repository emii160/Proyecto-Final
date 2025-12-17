pipeline {
    agent any

    environment {
        IMAGE_NAME = "proyecto-emilysofia"
        IMAGE_TAG  = "build-${env.BUILD_NUMBER}"
        DOCKERHUB_USER = "emilysofia-project"
        DOCKERHUB_REPO = "${DOCKERHUB_USER}/${IMAGE_NAME}"
        CONTAINER_NAME = "revision-proyecto"
    }

    stages {

        /* === CI #1: BUILD + PUSH === */

        stage('Clonar repositorio') {
            steps {
                echo "Clonando repositorio del proyecto Emily y Sofia"
                checkout scm
            }
        }

        stage('Construir imagen Docker') {
            steps {
                echo "Construyendo imagen consolidada con Docker Compose"
                sh 'docker-compose build --no-cache'
            }
        }

        stage('Etiquetar imagen') {
            steps {
                echo "Etiquetando imagen para Docker Hub"
                sh """
                    docker tag proyecto-emilysofia:latest ${DOCKERHUB_REPO}:${IMAGE_TAG}
                    docker tag proyecto-emilysofia:latest ${DOCKERHUB_REPO}:emily-sofia
                    echo "Tags aplicados: ${IMAGE_TAG} y emily-sofia"
                """
            }
        }

        stage('Subir imagen a Docker Hub') {
            steps {
                echo "Subiendo imagen al repositorio de Emily y Sofia"
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                        echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
                        docker push ${DOCKERHUB_REPO}:${IMAGE_TAG}
                        docker push ${DOCKERHUB_REPO}:emily-sofia
                        echo " Imagen subida exitosamente"
                    """
                }
            }
        }

        /* === CI #2: PULL + VALIDACIÓN === */

        stage('Descargar imagen desde Docker Hub') {
            steps {
                echo "Descargando imagen publicada"
                sh "docker pull ${DOCKERHUB_REPO}:${IMAGE_TAG}"
                sh "docker images | grep ${DOCKERHUB_REPO}"
            }
        }

        stage('Eliminar contenedor previo') {
            steps {
                sh "docker rm -f ${CONTAINER_NAME} 2>/dev/null || echo 'No había contenedor previo'"
            }
        }

        stage('Ejecutar contenedor') {
            steps {
                echo "Ejecutando contenedor de validación"
                sh """
                    docker run -d \
                        --name ${CONTAINER_NAME} \
                        --workdir /workspace \
                        ${DOCKERHUB_REPO}:${IMAGE_TAG} \
                        tail -f /dev/null
                    sleep 3
                """
            }
        }

        /* === VALIDACIONES DE HERRAMIENTAS === */

        stage('Verificar entorno del contenedor') {
            steps {
                echo "Verificando entorno base"
                sh """
                    echo "=== INFORMACIÓN DEL CONTENEDOR ==="
                    docker exec ${CONTAINER_NAME} cat /etc/os-release | grep PRETTY_NAME
                    docker exec ${CONTAINER_NAME} pwd
                """
            }
        }

        stage('Verificar versión de RPM') {
            steps {
                echo "Validando herramientas de construcción"
                sh """
                    docker exec ${CONTAINER_NAME} rpmbuild --version
                    docker exec ${CONTAINER_NAME} which createrepo_c && echo "createrepo_c disponible"
                """
            }
        }

        stage('Verificar versión de Ruby') {
            steps {
                echo "Validando Ruby y rbenv"
                sh """
                    docker exec ${CONTAINER_NAME} ruby -v
                    docker exec ${CONTAINER_NAME} bash -c 'rbenv versions'
                    docker exec ${CONTAINER_NAME} gem --version
                """
            }
        }

        stage('Verificar versiones de Node.js') {
            steps {
                echo "Validando Node.js y entorno"
                sh """
                    docker exec ${CONTAINER_NAME} bash -c "node -v"
                    docker exec ${CONTAINER_NAME} bash -c "npm -v"
                    docker exec ${CONTAINER_NAME} bash -c "yarn -v"
                    docker exec ${CONTAINER_NAME} bash -c "nvm list"
                """
            }
        }

        stage('Verificar versión de Python') {
            steps {
                echo "Validando Python y entorno virtual"
                sh """
                    docker exec ${CONTAINER_NAME} python3 --version
                    docker exec ${CONTAINER_NAME} which python3
                    docker exec ${CONTAINER_NAME} python3 -m pip --version
                """
            }
        }

        stage('Prueba de ejecución Python') {
            steps {
                echo "Ejecutando prueba de Python"
                sh """
                    docker exec ${CONTAINER_NAME} python3 -c "
print(' Proyecto Emily y Sofia funcionando')
print('Python ejecutándose correctamente')
print('---')
import sys
print(f'Versión Python: {sys.version}')
                    "
                """
            }
        }

        /* === VALIDACIONES ADICIONALES (nuevas) === */

        stage('Verificar herramientas adicionales') {
            steps {
                echo "Validando herramientas instaladas"
                sh """
                    echo "=== GIT ==="
                    docker exec ${CONTAINER_NAME} git --version
                    
                    echo "=== CURL ==="
                    docker exec ${CONTAINER_NAME} curl --version | head -1
                    
                    echo "=== SONARSCANNER ==="
                    docker exec ${CONTAINER_NAME} which sonar-scanner && echo "SonarScanner disponible" || echo "SonarScanner no encontrado"
                """
            }
        }

        stage('Prueba de comando personalizado') {
            steps {
                echo "Ejecutando comando de validación final"
                sh """
                    docker exec ${CONTAINER_NAME} bash -c '
                        echo "=== VALIDACIÓN FINAL ==="
                        echo "Proyecto: Emily y Sofia"
                        echo "Imagen: ${DOCKERHUB_REPO}:${IMAGE_TAG}"
                        echo "Fecha: $(date)"
                        echo "Herramientas verificadas: Ruby, Node.js, Python, RPM"
                        echo "Estado:  TODO FUNCIONA CORRECTAMENTE"
                    '
                """
            }
        }
    }

    post {
        always {
            echo "Realizando limpieza de contenedores"
            sh """
                docker stop ${CONTAINER_NAME} 2>/dev/null || true
                docker rm -f ${CONTAINER_NAME} 2>/dev/null || true
                echo "Contenedores limpiados"
            """
        }
        success {
            echo " Pipeline ejecutado correctamente por Emily y Sofia"
            echo " Imagen disponible en: ${DOCKERHUB_REPO}:${IMAGE_TAG}"
            echo " URL: https://hub.docker.com/r/${DOCKERHUB_USER}/${IMAGE_NAME}"
        }
        failure {
            echo " Error en el pipeline - Revisar logs"
        }
    }
}