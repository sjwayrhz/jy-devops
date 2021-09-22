package org.devops

//格式化输出
def PrintMes(value,color){
    colors = ['red'   : "\033[40;31m >>>>>>>>>>>${value}<<<<<<<<<<< \033[40;31m",
              'blue'  : "\033[47;34m >>>>>>>>>>>${value}<<<<<<<<<<< \033[47;34m",
              'green' : "\033[40;32m >>>>>>>>>>>${value}<<<<<<<<<<< \033[40;32m" ,
              'yellow' : "\033[1;33m >>>>>>>>>>>${value}<<<<<<<<<<< \033[1;33m" ,
              'purple' : "\033[0;35m${value}\033[0;35m"]
    ansiColor('xterm') {
        println(colors[color])
    }
}

