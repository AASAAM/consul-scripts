#!/bin/bash

warningping="10"
faildping="50"

proxy=''
http='http://www.google.com/robots.txt'
https='https://www.google.com/robots.txt'
ping='4.2.2.4'

SELFSCRIPTNAME=$(basename $0)

function usage()
{
    echo "Internet Access - Consule Script"
    echo ""
    echo "$SELFSCRIPTNAME"
    echo "  -h --help"
    echo "  --https=$http HTTPS endpoint for test"
    echo "  --http=$https HTTP endpoint for test"
    echo "  --ping=$ping Ping endpoint for test"
    echo "  --proxy=$proxy HTTP proxy for http(s) request"
    echo "  --warningping=$warningping Ping max packet loss as warning"
    echo "  --faildping=$faildping Ping max packet loss as faild"
}

while [ "$1" != "" ]; do
  PARAM=`echo $1 | awk -F= '{print $1}'`
  VALUE=`echo $1 | awk -F= '{print $2}'`
  case $PARAM in
    -h | --help)
      usage
      exit
      ;;
    --https)
      https=$VALUE
      ;;
    --http)
      http=$VALUE
      ;;
    --ping)
      ping=$VALUE
      ;;
    --proxy)
      proxy=$VALUE
      ;;
    --warningping)
      warningping=$VALUE
      ;;
    --faildping)
      faildping=$VALUE
      ;;
    *)
      echo "ERROR: unknown parameter \"$PARAM\""
      usage
      exit 1
      ;;
  esac
  shift
done

PINGLOSS=`ping -c 5 -q $ping | grep -oP '\d+(?=% packet loss)'`

if [ "$PINGLOSS" -gt "$faildping" ]; then
  echo "Packet loss $PINGLOSS%. FAILD"
  exit 2
fi

if [ "$PINGLOSS" -gt "$warningping" ]; then
  echo "Packet loss $PINGLOSS%. WARNING"
  exit 1
fi

if [[ -n "$proxy" ]]; then
  echo "Using proxy $proxy"
  http_proxy="$proxy"
  https_proxy="$proxy"
fi

HTTP_RESPONSE=`curl -s -o /dev/null -I -w "%{http_code}" $http`

if [ "$HTTP_RESPONSE" != "200" ]; then
  echo "HTTP status code for $http is $HTTP_RESPONSE. FAILD"
  exit 2
fi

HTTPS_RESPONSE=`curl -s -o /dev/null -I -w "%{http_code}" $https`

if [ "$HTTPS_RESPONSE" != "200" ]; then
  echo "HTTP status code for $https is $HTTPS_RESPONSE. FAILD"
  exit 2
fi

echo "OK"
exit 0
