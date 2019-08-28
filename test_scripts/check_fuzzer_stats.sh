#!/bin/bash
usage() { 
  echo "Usage: $0 -o <out_dir> -k <key> -v <value> [-p <precision>]" 1>&2;
  echo " " 1>&2;
  echo "Checks if a key:value appears in the fuzzer_stats report" 1>&2;
  echo " " 1>&2;
  echo -n "If \"value\" is numeric and \"precision\" is defined, checks if the stat " 1>&2;
  echo "printed by afl is value+/-precision." 1>&2; 
  exit 1; }

while getopts "o:k:v:p:" opt;  do
  case "${opt}" in
      o)
        o=${OPTARG}
        ;;
      k)
        k=${OPTARG}
        ;;
      v)
        v=${OPTARG}
        ;;
      p)
        p=${OPTARG}
        ;;
      *)
        usage
        ;;
  esac
done

if [ -z $o ] || [ -z $k ] || [ -z $v ]; then usage; fi

stat_v=$(grep $k "$o"/fuzzer_stats | cut -d ":" -f 2 )
if [ -z stat_v ]; 
  then echo "ERROR: key $k not found in fuzzer_stats." 1>&2 
  exit 1
fi

re='^[0-9]+([.][0-9]+)?$'
# if the argument is not a number, we check for strict equality
if ! [[  $v =~ $re ]]; 
  then if [ $v != $stat_v ];
    then echo "ERROR: \"$k:$stat_v\" (should be $v)." 1>&2 
    exit 2;
  fi
# checks if the stat reported by afl is in the range
elif [ $stat_v -lt $(( v - p )) ] || [ $stat_v -gt $(( v + p )) ];
  then echo "ERROR: key $k is out of correct range." 1>&2 
  exit 3;
fi
