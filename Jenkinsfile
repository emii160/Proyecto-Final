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
                bat 'timeout /t 5'
            }
        }

        stage('Verify Environment') {
            steps {
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
