pipeline {
    agent any

    environment {
        SONARQUBE = 'ConexionJenkins'       
        DOCKER_IMAGE = 'proyecto-final-devstack'
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/emii160/Proyecto-Final.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker compose down || true'
                sh 'docker compose up -d --build'
            }
        }

        stage('Verify Environment') {
            steps {
                sh 'docker compose exec devstack ruby --version'
                sh 'docker compose exec devstack node -v'
                sh 'docker compose exec devstack python3 --version'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarServer') {
                    sh '''
                    sonar-scanner \
                    -Dsonar.projectKey=ProyectoFinal \
                    -Dsonar.sources=. \
                    -Dsonar.host.url=$SONAR_HOST_URL \
                    -Dsonar.login=$SONAR_AUTH_TOKEN
                    '''
                }
            }
        }

        stage('Run JMeter') {
            steps {
                sh '''
                docker compose exec devstack bash -lc "
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
