pipeline {
    agent any

    environment {
        IMAGE_NAME = "alma8-full"
        IMAGE_TAG  = "proyecto-final"
        DOCKERHUB_USER = "emily06"  // Cambiado de yeyo19 a tu usuario
        DOCKERHUB_REPO = "${DOCKERHUB_USER}/${IMAGE_NAME}"
        CONTAINER_NAME = "alma8_revision"
        DOCKER_REGISTRY = "docker.io"  // Añadido para claridad
    }

    stages {
        /* CI #1: BUILD + PUSH */
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
                    docker tag alma8-full:latest ${env.DOCKERHUB_REPO}:${env.IMAGE_TAG}
                    docker tag alma8-full:latest ${env.DOCKERHUB_REPO}:latest
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
                        docker push ${env.DOCKERHUB_REPO}:${env.IMAGE_TAG}
                        docker push ${env.DOCKERHUB_REPO}:latest
                    """
                }
            }
        }

        /* CI #2: PULL + VALIDACIÓN */
        stage('Descargar imagen desde Docker Hub') {
            steps {
                bat "docker pull ${env.DOCKERHUB_REPO}:${env.IMAGE_TAG}"
            }
        }

        stage('Eliminar contenedor previo') {
            steps {
                bat "docker rm -f ${env.CONTAINER_NAME} || exit 0"
            }
        }

        stage('Ejecutar contenedor') {
            steps {
                bat """
                    docker run -d \
                      --name ${env.CONTAINER_NAME} \
                      -v ${WORKSPACE}:/workspace \
                      ${env.DOCKERHUB_REPO}:${env.IMAGE_TAG} \
                      tail -f /dev/null
                """
                bat 'timeout /t 10 /nobreak > nul'  // Esperar que el contenedor inicie
            }
        }

        stage('Verificar entorno de desarrollo') {
            steps {
                bat "docker exec ${env.CONTAINER_NAME} bash -lc \"ruby --version\""
                bat "docker exec ${env.CONTAINER_NAME} bash -lc \"node --version\""
                bat "docker exec ${env.CONTAINER_NAME} bash -lc \"npm --version\""
                bat "docker exec ${env.CONTAINER_NAME} bash -lc \"yarn --version\""
                bat "docker exec ${env.CONTAINER_NAME} bash -lc \"python3 --version\""
                bat "docker exec ${env.CONTAINER_NAME} bash -lc \"jmeter --version\""
                bat "docker exec ${env.CONTAINER_NAME} bash -lc \"sonar-scanner --version\""
            }
        }

        /* NUEVA ETAPA: Análisis SonarQube */
        stage('Análisis SonarQube') {
            when {
                expression { 
                    env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'develop' 
                }
            }
            steps {
                withSonarQubeEnv('ConexionJenkins') {
                    script {
                        // Ejecutar SonarQube Scanner dentro del contenedor
                        bat """
                            docker exec ${env.CONTAINER_NAME} bash -lc "
                                source /etc/profile.d/devstack.sh && \
                                cd /workspace && \
                                sonar-scanner \
                                -Dsonar.projectKey=ProyectoFinal \
                                -Dsonar.sources=. \
                                -Dsonar.host.url=${env.SONAR_HOST_URL} \
                                -Dsonar.login=${env.SONAR_AUTH_TOKEN} \
                                -Dsonar.projectVersion=${env.BUILD_NUMBER}
                            "
                        """
                    }
                }
            }
        }

        /* NUEVA ETAPA: Pruebas con JMeter */
        stage('Ejecutar pruebas JMeter') {
            when {
                expression { fileExists('test/jmeter') }
            }
            steps {
                script {
                    // Buscar archivos .jmx en el proyecto
                    def jmxFiles = findFiles(glob: '**/*.jmx')
                    
                    if (jmxFiles) {
                        jmxFiles.each { jmxFile ->
                            echo "Ejecutando prueba JMeter: ${jmxFile.name}"
                            bat """
                                docker exec ${env.CONTAINER_NAME} bash -lc "
                                    cd /workspace && \
                                    jmeter -n -t ${jmxFile.name} -l results.jtl -j jmeter.log
                                "
                            """
                        }
                    } else {
                        echo "No se encontraron archivos .jmx para pruebas JMeter"
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Limpiando contenedores"
            bat "docker rm -f ${env.CONTAINER_NAME} || exit 0"
        }
        success {
            echo "✅ Pipeline ejecutado correctamente"
            // Opcional: Notificar éxito
        }
        failure {
            echo "❌ Error en el pipeline"
            // Opcional: Notificar fallo
        }
    }
}