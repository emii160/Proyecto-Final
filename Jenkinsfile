pipeline {
    agent any

    environment {
        SONARQUBE = 'ConexionJenkins'
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/emii160/Proyecto-Final.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                bat 'docker-compose down || exit 0'
                bat 'docker-compose up -d --build'

                :: Esperar 5 segundos sin usar timeout
                bat 'ping -n 6 127.0.0.1 > nul'
            }
        }

        stage('Verify Environment') {
            steps {

                :: Verificar que el contenedor esté listo
                bat 'docker-compose exec devstack bash -lc "echo OK"'

                bat 'docker-compose exec devstack ruby --version'
                bat 'docker-compose exec devstack node -v'
                bat 'docker-compose exec devstack python3 --version'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('ConexionJenkins') {
                    bat '''
                    sonar-scanner ^
                        -Dsonar.projectKey=ProyectoFinal ^
                        -Dsonar.sources=. ^
                        -Dsonar.host.url=%SONAR_HOST_URL% ^
                        -Dsonar.login=%SONAR_AUTH_TOKEN%
                    '''
                }
            }
        }

        stage('Run JMeter') {
            steps {
                bat '''
                docker-compose exec devstack bash -lc "
                    jmeter -n -t tests/test-plan.jmx -l results/result.jtl
                "
                '''
            }
        }
    }

    post {
        always {
            echo "Pipeline finalizado."
        }
    }
}
