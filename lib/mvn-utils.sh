#!/bin/bash

artifactVersion() {

  if (( $# < 1 ))
  then
    echo "Usage:"
    echo "   $(basename $0) <pom-file>"
    exit 1
  fi

  pom_file=$1

  if [ ! -f $pom_file ]
  then
    error "File not found: [$pom_file]"
  fi

  mvn -f $pom_file org.apache.maven.plugins:maven-help-plugin:3.1.0:evaluate -Dexpression=project.version -q -DforceStdout
}
