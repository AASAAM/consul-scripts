#!/bin/bash

faild1=150
faild5=120
faild15=95
warning1=100
warning5=80
warning15=60

SELFSCRIPTNAME=$(basename $0)

function usage()
{
    echo "Load average - Consule Script"
    echo ""
    echo "$SELFSCRIPTNAME"
    echo "  -h --help"
    echo "  --warning1=$warning1 Warning percentage for 1 minutes"
    echo "  --warning5=$warning5 Warning percentage for 5 minutes"
    echo "  --warning15=$warning15 Warning percentage for 15 minutes"
    echo "  --faild1=$faild1 Faild percentage for 15 minutes"
    echo "  --faild5=$faild5 Faild percentage for 15 minutes"
    echo "  --faild15=$faild15 Faild percentage for 15 minutes"
}

while [ "$1" != "" ]; do
  PARAM=`echo $1 | awk -F= '{print $1}'`
  VALUE=`echo $1 | awk -F= '{print $2}'`
  case $PARAM in
    -h | --help)
      usage
      exit
      ;;
    --warning1)
      warning1=$VALUE
      ;;
    --warning5)
      warning5=$VALUE
      ;;
    --warning15)
      warning15=$VALUE
      ;;
    --faild1)
      faild1=$VALUE
      ;;
    --faild5)
      faild5=$VALUE
      ;;
    --faild15)
      faild15=$VALUE
      ;;
    *)
      echo "ERROR: unknown parameter \"$PARAM\""
      usage
      exit 1
      ;;
  esac
  shift
done

THREADS=`grep -c ^processor /proc/cpuinfo`
LOAD_1=`cut -d ' ' -f1 /proc/loadavg`
LOAD_5=`cut -d ' ' -f2 /proc/loadavg`
LOAD_15=`cut -d ' ' -f3 /proc/loadavg`

PERCENT_1=$(echo "($LOAD_1/$THREADS*100)/1" | bc -l | xargs printf "%.0f\n")
PERCENT_5=$(echo "($LOAD_5/$THREADS*100)/1" | bc -l | xargs printf "%.0f\n")
PERCENT_15=$(echo "($LOAD_15/$THREADS*100)/1" | bc -l | xargs printf "%.0f\n")

if [ "$PERCENT_1" -gt "$faild1" ] || [ "$PERCENT_5" -gt "$faild5" ] || [ "$PERCENT_15" -gt "$faild15" ]; then
  echo "FAILD"
  exit 2
fi

if [ "$PERCENT_1" -gt "$warning1" ] || [ "$PERCENT_5" -gt "$warning5" ] || [ "$PERCENT_15" -gt "$warning15" ]; then
  echo "WARNING"
  exit 1
fi

echo "OK"
exit 0

