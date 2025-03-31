pipeline {
    agent none
    triggers {
        upstream(upstreamProjects: 'UCSB-PSTAT GitHub/jupyter-base/main', threshold: hudson.model.Result.SUCCESS)
    }
    environment {
        IMAGE_NAME = 'eemb192a'
    }
    stages {
        stage('Build Test Deploy') {
            agent {
                kubernetes {
                    cloud 'rke-test'
                    inheritFrom 'podman'
                }
            }
            stages{
                stage('Build') {
                    steps {
                        script {
                            if (currentBuild.getBuildCauses('com.cloudbees.jenkins.GitHubPushCause').size() || currentBuild.getBuildCauses('jenkins.branch.BranchIndexingCause').size()) {
                               scmSkip(deleteBuild: true, skipPattern:'.*\\[ci skip\\].*')
                            }
                        }
                        container('podman') {
                            echo "NODE_NAME = ${env.NODE_NAME}"
                            sh 'podman build -t localhost/$IMAGE_NAME --pull --force-rm --no-cache .'
                        }
                     }
                    post {
                        unsuccessful {
                            container('podman') {
                                sh 'podman rmi -i localhost/$IMAGE_NAME || true'
                            }
                        }
                    }
                }
                stage('Test') {
                    steps {
                        container('podman') {
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME fastqc --version' 
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME trimmomatic -version'
                            // This is a test for BBTools
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME which conda_build.sh'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME megahit --version'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME spades.py --version'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME quast --version'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME bowtie2 --version'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME mamba run -n anvio-8 concoct --version'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME metabat --help'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME which run_MaxBin.pl'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME DAS_Tool --version'
                            // This is a test for gtdbtk
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME which download-db.sh'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME prodigal -v'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME prokka --version'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME DRAM.py -h'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME mamba run -n anvio-8 which checkm2'
                            // This is a test for GToTree
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME which gtt-test.sh'
                            //sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME python -c "import <library>;"'
                            sh 'podman run -d --name=$IMAGE_NAME --rm --pull=never -p 8888:8888 localhost/$IMAGE_NAME start-notebook.sh --NotebookApp.token="jenkinstest"'
                            sh 'sleep 10 && curl -v http://localhost:8888/lab?token=jenkinstest 2>&1 | grep -P "HTTP\\S+\\s200\\s+[\\w\\s]+\\s*$"'
                            sh 'curl -v http://localhost:8888/tree?token=jenkinstest 2>&1 | grep -P "HTTP\\S+\\s200\\s+[\\w\\s]+\\s*$"'
                        }
                    }
                    post {
                        always {
                            container('podman') {
                                sh 'podman rm -ifv $IMAGE_NAME'
                            }
                        }
                        unsuccessful {
                            container('podman') {
                                sh 'podman rmi -i localhost/$IMAGE_NAME || true'
                            }
                        }
                    }
                }
                stage('Deploy') {
                    when { branch 'main' }
                    environment {
                        DOCKER_HUB_CREDS = credentials('DockerHubToken')
                    }
                    steps {
                        container('podman') {
                            sh 'skopeo copy containers-storage:localhost/$IMAGE_NAME docker://docker.io/ucsb/$IMAGE_NAME:latest --dest-username $DOCKER_HUB_CREDS_USR --dest-password $DOCKER_HUB_CREDS_PSW'
                            sh 'skopeo copy containers-storage:localhost/$IMAGE_NAME docker://docker.io/ucsb/$IMAGE_NAME:v$(date "+%Y%m%d") --dest-username $DOCKER_HUB_CREDS_USR --dest-password $DOCKER_HUB_CREDS_PSW'
                        }
                    }
                    post {
                        always {
                            container('podman') {
                                sh 'podman rmi -i localhost/$IMAGE_NAME || true'
                            }
                        }
                    }
                }                
            }
        }
    }
    post {
        success {
            slackSend(channel: '#infrastructure-build', username: 'jenkins', color: 'good', message: "Build ${env.JOB_NAME} ${env.BUILD_NUMBER} just finished successfull! (<${env.BUILD_URL}|Details>)")
        }
        failure {
            slackSend(channel: '#infrastructure-build', username: 'jenkins', color: 'danger', message: "Uh Oh! Build ${env.JOB_NAME} ${env.BUILD_NUMBER} had a failure! (<${env.BUILD_URL}|Find out why>).")
        }
    }
}
