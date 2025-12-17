pipeline {
    agent any

    environment {
        IMAGE_NAME = "proyecto-fullstack"
        IMAGE_TAG = "v${env.BUILD_NUMBER}"
        DOCKERHUB_USER = "emilysofia"
        DOCKERHUB_REPO = "${DOCKERHUB_USER}/${IMAGE_NAME}"
        CONTAINER_NAME = "revision-proyecto"
    }

    stages {
        /* === FASE 1: CONSTRUCCIÓN Y PUBLICACIÓN === */
        
        stage('Obtener código') {
            steps {
                echo "- Obteniendo código del repositorio 'proyecto'"
                checkout scm
            }
        }

        stage(' Construir imagen') {
            steps {
                echo "Construyendo imagen Docker con todas las herramientas"
                sh 'docker-compose build --no-cache'
            }
        }

        stage('  Etiquetar imagen') {
            steps {
                echo "Etiquetando imagen para Docker Hub"
                sh """
                    docker tag proyecto-fullstack:latest ${DOCKERHUB_REPO}:${IMAGE_TAG}
                    docker tag proyecto-fullstack:latest ${DOCKERHUB_REPO}:latest
                    docker tag proyecto-fullstack:latest ${DOCKERHUB_REPO}:emily-sofia
                """
            }
        }

        stage('⬆️  Publicar en Docker Hub') {
            steps {
                echo "Subiendo imagen al repositorio de Emily y Sofia"
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                        echo \${DOCKER_PASS} | docker login -u \${DOCKER_USER} --password-stdin
                        
                        echo "Publicando etiquetas..."
                        docker push ${DOCKERHUB_REPO}:${IMAGE_TAG}
                        docker push ${DOCKERHUB_REPO}:latest
                        docker push ${DOCKERHUB_REPO}:emily-sofia
                        
                        echo " Imágenes publicadas por Emily y Sofia"
                    """
                }
            }
        }

        /* === FASE 2: VERIFICACIÓN === */
        
        stage(' Obtener imagen publicada') {
            steps {
                echo "Descargando imagen para verificación"
                sh """
                    docker pull ${DOCKERHUB_REPO}:${IMAGE_TAG}
                    echo "Versión descargada: ${IMAGE_TAG}"
                """
            }
        }

        stage(' Ejecutar contenedor') {
            steps {
                echo "Iniciando contenedor de verificación"
                sh """
                    # Limpiar si existe
                    docker rm -f ${CONTAINER_NAME} 2>/dev/null || true
                    
                    # Ejecutar nuevo contenedor
                    docker run -d \
                        --name ${CONTAINER_NAME} \
                        ${DOCKERHUB_REPO}:${IMAGE_TAG} \
                        tail -f /dev/null
                """
            }
        }

        /* === VALIDACIONES CON NOMBRES PERSONALIZADOS === */
        
        stage('Verificar herramientas base') {
            steps {
                echo " verifica herramientas base"
                sh """
                    echo "=== HERRAMIENTAS DE DESARROLLO ==="
                    docker exec ${CONTAINER_NAME} rpmbuild --version | head -1
                    docker exec ${CONTAINER_NAME} git --version
                """
            }
        }

        stage('💎 Verificar Ruby') {
            steps {
                echo " verifica entorno Ruby"
                sh """
                    echo "=== ENTORNO RUBY ==="
                    docker exec ${CONTAINER_NAME} ruby -v
                    docker exec ${CONTAINER_NAME} bash -c 'rbenv versions'
                """
            }
        }

        stage(' Verificar Node.js') {
            steps {
                echo "verifica Node.js"
                sh """
                    echo "=== NODE.JS Y NPM ==="
                    docker exec ${CONTAINER_NAME} bash -c 'node -v'
                    docker exec ${CONTAINER_NAME} bash -c 'npm -v'
                    docker exec ${CONTAINER_NAME} bash -c 'yarn -v 2>/dev/null || echo "Yarn no disponible"'
                """
            }
        }

        stage(' Verificar Python') {
            steps {
                echo "verifica Python"
                sh """
                    echo "=== PYTHON 3 ==="
                    docker exec ${CONTAINER_NAME} python3 --version
                    docker exec ${CONTAINER_NAME} python3 -c "print('¡Hola desde el proyecto de Emily y Sofia!')"
                """
            }
        }

        stage(' Verificación final') {
            steps {
                echo "Verificación final del proyecto"
                sh """
                    echo "=== RESUMEN DEL ENTORNO ==="
                    docker exec ${CONTAINER_NAME} bash -c '
                        echo "Ruby: $(ruby -v)"
                        echo "Node: $(node -v)"
                        echo "Python: $(python3 --version)"
                        echo "Proyecto listo para producción"
                    '
                    
                    echo "=== INFORMACIÓN DEL CONTENEDOR ==="
                    docker inspect ${CONTAINER_NAME} --format='{{.Config.Image}}'
                """
            }
        }

        /* === ANÁLISIS OPCIONAL (Se puede activar después) === */
        
        stage(' Prueba rápida JMeter (Opcional)') {
            when {
                expression { params.RUN_JMETER == true }
            }
            steps {
                echo "Ejecutando prueba JMeter básica"
                sh """
                    docker exec ${CONTAINER_NAME} bash -c '
                        echo "Creando prueba básica JMeter..."
                        jmeter --version 2>/dev/null || echo "JMeter no configurado"
                    '
                """
            }
        }
    }

    post {
        always {
            echo "🧹 Limpiando recursos"
            sh """
                docker stop ${CONTAINER_NAME} 2>/dev/null || true
                docker rm -f ${CONTAINER_NAME} 2>/dev/null || true
                echo "Limpieza completada"
            """
        }
        success {
            echo " ¡Pipeline completado exitosamente por Emily y Sofia!"
            echo "Imagen disponible en: ${DOCKERHUB_REPO}:${IMAGE_TAG}"
        }
        failure {
            echo " Pipeline falló "
        }
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    parameters {
        booleanParam(
            name: 'RUN_JMETER',
            defaultValue: false,
            description: 'Ejecutar pruebas JMeter (requiere configuración previa)'
        )
    }
}