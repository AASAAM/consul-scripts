#!/bin/bash

faild=95
warning=75
swapfaild=70
swapwarning=40

SELFSCRIPTNAME=$(basename $0)

function usage()
{
    echo "Memory - Consule Script"
    echo ""
    echo "$SELFSCRIPTNAME"
    echo "  -h --help"
    echo "  --warning=$warning Warning percentage used memory"
    echo "  --faild=$faild Faild percentage used memory"
    echo "  --swapwarning=$swapwarning Warning percentage used swap memory"
    echo "  --swapfaild=$swapfaild Faild percentage used swap memory"
}

while [ "$1" != "" ]; do
  PARAM=`echo $1 | awk -F= '{print $1}'`
  VALUE=`echo $1 | awk -F= '{print $2}'`
  case $PARAM in
    -h | --help)
      usage
      exit
      ;;
    --warning)
      warning=$VALUE
      ;;
    --faild)
      faild=$VALUE
      ;;
    *)
      echo "ERROR: unknown parameter \"$PARAM\""
      usage
      exit 1
      ;;
  esac
  shift
done

TOTALMEM=`grep MemTotal /proc/meminfo | awk '{print $2}'`
TOTALSWAP=`grep SwapTotal /proc/meminfo | awk '{print $2}'`
FREEMEM=`grep MemFree /proc/meminfo | awk '{print $2}'`
FREESWAP=`grep SwapFree /proc/meminfo | awk '{print $2}'`
USEDMEM=`expr $TOTALMEM - $FREEMEM`
USEDSWAP=`expr $TOTALSWAP - $FREESWAP`

USEDMEMPER=$(echo "($USEDMEM/$TOTALMEM*100)/1" | bc -l | xargs printf "%.0f\n")
USEDSWAPPER=$(echo "($USEDSWAP/$TOTALSWAP*100)/1" | bc -l | xargs printf "%.0f\n")

if [ "$USEDMEMPER" -gt "$faild" ] || [ "$USEDSWAPPER" -gt "$swapfaild" ]; then
  echo "FAILD"
  exit 2
fi

if [ "$USEDMEMPER" -gt "$warning" ] || [ "$USEDSWAPPER" -gt "$swapwarning" ]; then
  echo "WARNING"
  exit 1
fi

echo "OK"
exit 0
