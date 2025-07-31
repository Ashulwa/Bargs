#!/bin/bash
script_name='Bargs Example'
script_description='this script showcases how to use bargs'
script_usage="$0 <positionalArg> [-s] [-v value] [-e value]"

myargs=(
	'|positionalArg|a positional argument|'
	's|switch|a switch argument|'
	'v|value|a value argument, stores a value|#$val'
	'p|print|print, modify and store value while parsing|echo "$val";val="Printed-$val"'
)
source ./bargs.sh

cat <<-EOF
	  --- Values ---
	switch:  $ARGS_switch
	value:   $ARGS_value
	print:   $ARGS_print
	positionalArg: $ARGS_positionalArg
	POSARGS Array: ( ${POSARGS[*]} )
EOF
