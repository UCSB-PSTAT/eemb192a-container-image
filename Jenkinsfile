pipeline {
    agent none
    triggers {
        upstream(upstreamProjects: 'UCSB-PSTAT GitHub/jupyter-base/main', threshold: hudson.model.Result.SUCCESS)
    }
    environment {
        IMAGE_NAME = 'eemb192a'
        CONTAINER_REGISTRY  = 'registry.cloud.college.ucsb.edu'
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
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME mamba run -n anvio fastqc --version' 
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME mamba run -n anvio trimmomatic -version'
                            // This is a test for BBTools
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME mamba run -n anvio which conda_build.sh'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME mamba run -n anvio megahit --version'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME mamba run -n anvio spades.py --version'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME mamba run -n anvio quast --version'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME mamba run -n anvio bowtie2 --version'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME mamba run -n anvio concoct --version'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME mamba run -n anvio metabat --help'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME mamba run -n anvio which run_MaxBin.pl'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME mamba run -n anvio DAS_Tool --version'
                            // This is a test for gtdbtk
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME mamba run -n anvio which download-db.sh'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME mamba run -n anvio prodigal -v'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME mamba run -n anvio prokka --version'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME mamba run -n anvio DRAM.py -h'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME mamba run -n checkm2 which checkm2'
                            // This is a test for GToTree
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME mamba run -n anvio which gtt-test.sh'
                            //sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME python -c "import <library>;"'
                            sh 'podman run -d --name=$IMAGE_NAME --rm --pull=never -p 8888:8888 localhost/$IMAGE_NAME start-notebook.sh --NotebookApp.token="jenkinstest"'
                            retry(6) { sh 'sleep 10 && curl -v http://localhost:8888/lab?token=jenkinstest 2>&1 | grep -P "HTTP\\S+\\s200\\s+[\\w\\s]+\\s*$"' }
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
                        DOCKER_HUB_CREDS = credentials('harbor-registry-token')
                    }
                    steps {
                        container('podman') {
                            sh 'skopeo copy containers-storage:localhost/$IMAGE_NAME docker://$CONTAINER_REGISTRY/ucsb/$IMAGE_NAME:latest --dest-username $DOCKER_HUB_CREDS_USR --dest-password $DOCKER_HUB_CREDS_PSW'
                            sh 'skopeo copy containers-storage:localhost/$IMAGE_NAME docker://$CONTAINER_REGISTRY/ucsb/$IMAGE_NAME:v$(date "+%Y%m%d") --dest-username $DOCKER_HUB_CREDS_USR --dest-password $DOCKER_HUB_CREDS_PSW'
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
            slackSend(username: 'jenkins', color: 'good', message: "Build ${env.JOB_NAME} ${env.BUILD_NUMBER} just finished successfull! (<${env.BUILD_URL}|Details>)")
        }
        failure {
            slackSend(username: 'jenkins', color: 'danger', message: "Uh Oh! Build ${env.JOB_NAME} ${env.BUILD_NUMBER} had a failure! (<${env.BUILD_URL}|Find out why>).")
        }
    }
}
