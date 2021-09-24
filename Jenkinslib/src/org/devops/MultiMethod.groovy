package org.devops

class MultiMethod {
    def steps;
    MultiMethod(steps) {
        this.steps = steps
    }
    def foo() {
        steps.echo "Hello foo from src/org/devops/MultiMethod.groovy"
    }
    def bar() {
        steps.echo "Hello bar from src/org/devops/MultiMethod.groovy"
    }
}