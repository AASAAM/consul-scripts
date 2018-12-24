#!/bin/bash

warning=80
faild=90

SELFSCRIPTNAME=$(basename $0)

function usage()
{
    echo "Disk Usage - Consule Script"
    echo ""
    echo "$SELFSCRIPTNAME"
    echo "  -h --help"
    echo "  --warning=$warning Warning percentage used"
    echo "  --faild=$faild Faild percentage used"
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

IS_WARNING=0
IS_FAILD=0

DISPLAYFS=`df --o -a -t ext4 -t ext3 -t ext2 -t xfs -t btrfs -t tmpfs -t aufs | tail -n +2`

while read -r LN; do
  INODEUSAGE=`echo $LN | awk '{print $6}' | tr -dc '0-9'`
  USAGE=`echo $LN | awk '{print $10}' | tr -dc '0-9'`
  if [[ -n "$INODEUSAGE" ]]; then
    if [ "$INODEUSAGE" -gt "$faild" ]; then
      IS_FAILD=1
    elif [ "$INODEUSAGE" -gt "$warning" ]; then
      IS_WARNING=1
    fi
  fi
  if [[ -n "$USAGE" ]]; then
    if [ "$USAGE" -gt "$faild" ]; then
      IS_FAILD=1
    elif [ "$USAGE" -gt "$warning" ]; then
      IS_WARNING=1
    fi
  fi
done <<< "$DISPLAYFS"

if [ "$IS_FAILD" = "1" ]; then
  echo "FAILD"
  exit 2
fi

if [ "$IS_WARNING" = "1" ]; then
  echo "WARNING"
  exit 1
fi

echo "OK"
exit 0

