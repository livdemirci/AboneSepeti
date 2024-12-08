pipeline {
    agent any
    environment {
        BUNDLE_PATH = '/tmp/bundle_path'
        PATH = "$HOME/.local/share/gem/ruby/3.2.0/bin:$PATH"
    }
    stages {
        stage('Cleanup Workspace') {
            steps {
                script {
                    // Çalışma alanını temizleyin
                    cleanWs()
                }
            }
        }
        stage('Checkout Code') {
            steps {
                script {
                    // GitHub reposunu çekin
                    git 'https://github.com/livdemirci/AboneSepeti.git'
                }
            }
        }
        stage('Setup Environment') {
            steps {
                script {
                    // Bağımlılıkları yükleyin
                    sh 'gem install bundler ci_reporter rspec --user-install'
                    sh 'bundle config set path $BUNDLE_PATH'
                    sh 'bundle install'
                }
            }
        }
        stage('Run Tests') {
            steps {
                script {
                    // Testlerinizi çalıştırın
                    sh 'bundle exec rspec'
                }
            }
        }
    }
}
