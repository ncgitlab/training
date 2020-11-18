  node {
    stage('checkout scm') {
      git credentialsId: 'git-cred', url: 'https://github.com/Ncgitlab/training.git'
    }
	stage('static code analysis-2'){

		sh 'cd $WORKSPACE/OT-Java-WebApp;mvn cobertura:cobertura;mvn sonar:sonar'
		}
		stage('Build'){

		sh 'cd $WORKSPACE/OT-Java-WebApp;mvn install'
		}
		stage('Unit test'){
         junit testResults: '**/target/*-reports/TEST-*.xml'
		}
		stage('copying artifact to s3'){
         s3Upload consoleLogLevel: 'INFO', dontSetBuildResultOnFailure: false, dontWaitForConcurrentBuildCompletion: false, entries: [[bucket: 'awstesing-2020', excludedFile: '', flatten: false, gzipFiles: false, keepForever: false, managedArtifacts: false, noUploadOnFailure: true, selectedRegion: 'us-east-1', showDirectlyInBrowser: false, sourceFile: '**/*.war', storageClass: 'STANDARD', uploadFromSlave: false, useServerSideEncryption: false]], pluginFailureResultConstraint: 'FAILURE', profileName: 'artifact', userMetadata: []
		}
}
