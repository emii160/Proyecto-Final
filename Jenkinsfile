pipeline {
    agent any

    environment {
        IMAGE_NAME = "proyectofinal-devstack"
        IMAGE_TAG = "build-${env.BUILD_NUMBER}"
        DOCKERHUB_USER = "emilysofia-project"
        DOCKERHUB_REPO = "${DOCKERHUB_USER}/${IMAGE_NAME}"
        CONTAINER_NAME = "proyecto-test"
    }

    stages {
        /* === FASE 1: CONSTRUCCIÓN Y PUBLICACIÓN === */
        
        stage('Clonar repositorio') {
            steps {
                echo "Proyecto de Emily y Sofia"
                checkout scm
            }
        }

        stage('Construir imagen Docker') {
            steps {
                echo "Construyendo imagen con Docker Compose"
                bat 'docker compose down || exit 0'
                bat 'docker compose up -d --build'
                bat 'ping -n 6 127.0.0.1 >nul'
            }
        }

        stage('Etiquetar imagen') {
            steps {
                echo "Etiquetando imagen para Docker Hub"
                bat """
                    docker tag proyectofinal-devstack:latest %DOCKERHUB_REPO%:%IMAGE_TAG%
                    docker tag proyectofinal-devstack:latest %DOCKERHUB_REPO%:emily-sofia
                """
            }
        }

        stage('Subir a Docker Hub') {
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
                        docker push %DOCKERHUB_REPO%:emily-sofia
                    """
                }
            }
        }

        /* === FASE 2: VALIDACIÓN Y PRUEBAS === */
        
        stage('Descargar imagen') {
            steps {
                echo "Descargando imagen desde Docker Hub"
                bat 'docker pull %DOCKERHUB_REPO%:%IMAGE_TAG%'
            }
        }

        stage('Ejecutar contenedor de prueba') {
            steps {
                echo "Ejecutando contenedor para validación"
                bat """
                    docker rm -f %CONTAINER_NAME% || exit 0
                    docker run -d --name %CONTAINER_NAME% %DOCKERHUB_REPO%:%IMAGE_TAG% tail -f /dev/null
                    ping -n 5 127.0.0.1 >nul
                """
            }
        }

        stage('Verificar herramientas RPM') {
            steps {
                echo "Validando herramientas de construcción"
                bat '''
                    echo === HERRAMIENTAS RPM ===
                    docker exec %CONTAINER_NAME% rpm --version
                    docker exec %CONTAINER_NAME% rpmbuild --version 2>nul || echo "rpmbuild no disponible"
                '''
            }
        }

        stage('Verificar Ruby y rbenv') {
            steps {
                echo "Validando entorno Ruby"
                bat '''
                    echo === RUBY Y RBENV ===
                    docker exec %CONTAINER_NAME% ruby --version
                    docker exec %CONTAINER_NAME% bash -lc "rbenv versions"
                    docker exec %CONTAINER_NAME% gem --version
                '''
            }
        }

        stage('Verificar Node.js y npm') {
            steps {
                echo "Validando Node.js"
                bat '''
                    echo === NODE.JS ===
                    docker exec %CONTAINER_NAME% bash -lc "node --version"
                    docker exec %CONTAINER_NAME% bash -lc "npm --version"
                    docker exec %CONTAINER_NAME% bash -lc "yarn --version 2>/dev/null || echo 'yarn no instalado'"
                '''
            }
        }

        stage('Verificar Python') {
            steps {
                echo "Validando Python"
                bat '''
                    echo === PYTHON ===
                    docker exec %CONTAINER_NAME% python3 --version
                    docker exec %CONTAINER_NAME% bash -lc "python3 -m pip --version"
                '''
            }
        }

        stage('Prueba de ejecución') {
            steps {
                echo "Ejecutando prueba final"
                bat '''
                    echo === PRUEBA FINAL ===
                    docker exec %CONTAINER_NAME% python3 -c "print('¡Hola desde el proyecto de Emily y Sofia!')"
                    docker exec %CONTAINER_NAME% bash -lc "echo ' Todas las herramientas funcionan correctamente'"
                '''
            }
        }

        stage('Verificación de imagen') {
            steps {
                echo "Verificando detalles de la imagen"
                bat """
                    echo === INFORMACIÓN DE LA IMAGEN ===
                    docker images | findstr "%DOCKERHUB_REPO%"
                    docker inspect %CONTAINER_NAME% --format="{{.Config.Image}}"
                    
                    echo === RESUMEN ===
                    echo "Imagen: %DOCKERHUB_REPO%:%IMAGE_TAG%"
                    echo "Build: %BUILD_NUMBER%"
                    echo "Estado: VALIDACIÓN EXITOSA"
                """
            }
        }
    }

    post {
        always {
            echo "Realizando limpieza"
            bat 'docker rm -f %CONTAINER_NAME% || exit 0'
            bat 'docker compose down || exit 0'
        }
        success {
            echo " Pipeline ejecutado correctamente por Emily y Sofia"
            echo " Imagen disponible en: ${DOCKERHUB_REPO}:${IMAGE_TAG}"
        }
        failure {
            echo " El pipeline falló"
        }
    }
}