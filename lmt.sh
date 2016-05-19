#!/bin/bash
# $1 operation: add remove
# $2 gatewayid
# $3 limitnumber
# $4 output string while limited

#if [ "${1}" != "add" -a "${1}" != "remove" -a "${1}" != "get" ]
#then
#        echo "operation must be ether add or remove or get!"
#fi

if ! [ ${2} ]
then
        echo "gatewayid must be not null"
fi

IP="10.213.42.58"
PORT="10379"
RETVAL=0
GATEWAYID="${2}"
LIMITNUM="${3}"
LIMITCONTENT="${4}"

add(){
	if ! [ ${LIMITNUM} ] 
	then
		echo "limit number must be not null"
		exit 1
	fi

	if ! [ ${LIMITCONTENT} ]
	then
		LIMITCONTENT=""
	fi

	/opt/redis/bin/redis-cli -h ${IP} -p ${PORT} hset limit ${GATEWAYID} ${LIMITNUM}
	/opt/redis/bin/redis-cli -h ${IP} -p ${PORT} hset limit "${GATEWAYID}_content" ${LIMITCONTENT}
	RETVAL=$?
	echo "add ${GATEWAYID} limit number ${LIMITNUM} and content ${LIMITCONTENT} completed"
}

remove(){
	/opt/redis/bin/redis-cli -h ${IP} -p ${PORT} hdel limit ${GATEWAYID} 
	/opt/redis/bin/redis-cli -h ${IP} -p ${PORT} hdel limit "${GATEWAYID}_content"
	RETVAL=$?
	echo "removed ${GATEWAYID} limit number and content completed"
}

get(){
	/opt/redis/bin/redis-cli -h ${IP} -p ${PORT} hget limit ${GATEWAYID} 
	/opt/redis/bin/redis-cli -h ${IP} -p ${PORT} hget limit "${GATEWAYID}_content"
	RETVAL=$?
	echo "get ${GATEWAYID} completed"

}

case "${1}" in
add)
        add
        ;;
remove)
        remove
        ;;
get)
	get
	;;
*)
        echo $"Usage: sh lmt.sh {add|remove|get} gatewayid limit_num limit_content"
        exit 1
esac
