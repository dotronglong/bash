#!/usr/bin/env bash

machineName=$2
if [ -z $machineName ]; then
    echo "MACHINE_NAME must be specified!"
    exit
fi
main() {
    case $1 in
        start)
            startSystem
        ;;

        stop)
            stopSystem
        ;;

        restart)
            stopSystem
            startSystem
        ;;

        *)
        echo "Usage: $0 {start|stop|restart} [MACHINE_NAME]"
        exit
    esac
}

setUpMachine() {
    machineStatus=$(docker-machine ls | grep $machineName | awk '{print $4}')
    if [ -z $machineStatus ]; then
        docker-machine create --driver virtualbox --virtualbox-cpu-count "2" --virtualbox-memory "2048" $machineName
    elif [ $machineStatus = "Stopped" ]; then
        docker-machine start $machineName
    fi
    eval $(docker-machine env $machineName)
}

startSystem() {
    setUpMachine
    docker-compose up -d

    systemStart="system.start"
    if [ -f $systemStart ]; then
        source $systemStart
    fi

    echo "System started!"
}

stopSystem() {
    setUpMachine
    docker-compose down

    systemStop="system.stop"
    if [ -f $systemStop ]; then
        source $systemStop
    fi

    echo "System stopped!"
}

main $@
