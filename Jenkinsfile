@Library(['github.com/indigo-dc/jenkins-pipeline-library@release/2.1.1']) _

def projectConfig

pipeline {
    agent any

    stages {
        stage('Application testing') {
            steps {
                script {
                    projectConfig = pipelineConfig()
                    buildStages(projectConfig)
                }
            }
        }
        // (optional) Publish testing results in Jenkins
        stage('Publish results in Jenkins') {
            steps { 
                script {
                    // file locations are defined in tox.ini
                    // publish results of the style analysis
                    recordIssues(tools: [flake8(pattern: 'flake8.log',
                                         name: 'PEP8 report',
                                         id: "flake8_pylint")])
                    // publish results of the coverage test
                    publishHTML([allowMissing: false, 
                                 alwaysLinkToLastBuild: false, 
                                 keepAll: true, 
                                 reportDir: "htmlcov", 
                                 reportFiles: 'index.html', 
                                 reportName: 'Coverage report', 
                                 reportTitles: ''])
                    // publish results of the security check
                    publishHTML([allowMissing: false, 
                                 alwaysLinkToLastBuild: false, 
                                 keepAll: true, 
                                 reportDir: "bandit", 
                                 reportFiles: 'index.html', 
                                 reportName: 'Bandit report', 
                                 reportTitles: ''])
                }
            }
        }
    }
    post {
        // Clean after build
        always {
            cleanWs()
        }    
    }
}