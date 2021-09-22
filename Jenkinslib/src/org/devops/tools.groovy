package org.devops

//格式化输出
def PrintMes(value,color){
    colors = ['red'   : "\033[0;32;31m >>>>>>>>>>>${value}<<<<<<<<<<< ",
              'blue'  : "\033[0;34m >>>>>>>>>>>${value}<<<<<<<<<<< ",
              'green' : "\033[1;32m >>>>>>>>>>>${value}<<<<<<<<<<< " ,
              'yellow' : "\033[1;33m >>>>>>>>>>>${value}<<<<<<<<<<< " ,
              'purple' : "\033[0;35m${value}"]
    ansiColor('xterm') {
        println(colors[color])
    }
}

