#!/usr/bin/env groovy

def call(String name) {
  echo "Hello, ${name}."
}

def callDeploy(String app) {
    switch (app) {
        case demo-spring-a:
            return hwy-1;            
        break
        case demo-spring-a:
            return hwy-1; 
        break
        default:
            return none;
        break
    }
}