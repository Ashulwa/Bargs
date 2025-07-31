#!/bin/bash
###############################################################################
##########################################
# ABOUT ####        ▛▀▖            
###########         ▙▄▘▝▀▖▙▀▖▞▀▌▞▀▘
#            v1.1   ▌ ▌▞▀▌▌  ▚▄▌▝▀▖
#                   ▀▀ ▝▀▘▘  ▗▄▘▀▀ 
# Bargs is an Argument parsing Module for Bash Scripts
# similar to yargs for nodejs or argparse for python
##################################################
##########################################
# USAGE #####
############
#
# 1. build the myargs array:
#      myargs=(
#          'shorthand|argname|helptext|runtext'
#          '...'
#          '...'
#      )
#
# 2. source this module file:
#      source ./path/to/bargs.sh
#
##################################################
##########################################
# DOCUMENTATION ####
###################
#
# each argument type is defined like so:
#	positional:		'|argname|help|runtext'
#	switch/flag:	'shorthand|argname|help|runtext'
#	value args:		'shorthand|argname|help|runtext "$val"'
#
######## General Stuff
# - all defined arguments will store their values in their own unique variable: $ARGS_argname
# - switches/flags will simply store the string 'True' as their $ARGS_value
# - positionals (defined or not) are stored in the "$POSARGS" array
# - help is a string that is displayed in the help menu
# - runtext is a string that will be executed if the argument is present
#
######## Naming/Triggering
# - shorthands and names do not use leading dashes when they are defined
# - the shorthand form is triggered on the commandline by: -shorthand
# - the fullname form is triggered on the commandline by: --argname
#
######## Positionals
# - positional arguments are defined by having an empty shorthand
# - defined positionals become required components
# - all positionals (defined or not) are stored within "$POSARGS" array
# - they are stored in the order they are recieved
#
######## Flags/Switches
# - flags/switches are arguments that dont need a value
# - they are defined by runtext that does not contain this exact string: $val
# - they will execute their runtext, and set their $ARGS_argname value as the string 'true'
#
######## Arguments that Hold a Supplied Value
# - value type arguments, are arguments that hold a user supplied value
# - they are defined by runtext that contains the string: $val
#
######## Run Text
# - runtext is optional, and will be executed when arg is found
# - the arguments value is accessible via "$val" within runtext
# - positionals will execute after all other arg types
#
# some Examples for runtext:
#	( 'sh|name|help|echo "${val}"' ) <-- will echo the arguments value
#	( 'sh|name|help|' ) <--------------- empty runtext is valid for both switches and positionals
#	( 'sh|name|help|#$val' ) <---------- this will define a value type argument
###################################################################

args=( "$@" )

### Help Menu
function showhelp() {
	echo "${script_example:-${script_name:-$0}}"
	echo "-----------------------------------"
	echo "${script_description:-"Define a Description"}"
	echo "-----------------------------------"
	for x in $(seq 1 ${#myargs[@]});do
			argument="${myargs[$((x-1))]}"
			argshort="$(echo "$argument"|cut -d '|' -f 1)"
			argname="$(echo "$argument"|cut -d '|' -f 2)"
			arghelp="$(echo "$argument"|cut -d '|' -f 3)"
						d='-'
			argtype="$(
					if [ ! "$argshort" ];then
						echo "positional"
					elif [[ "$(echo "$argument"|cut -d '|' -f 4-)" =~ '$val' ]];then
						echo "value"
					else
						echo "flag"
					fi
				)"
			[ "$argtype" == 'positional' ] && unset d
			echo "${d}$argshort ${d}${d}$argname	($argtype)	$arghelp"
	done|sort -h
	exit
}

### Parse and Handle Arguments
x=0
POSARGS=( )
while [ $x -lt ${#args[@]} ];do
	# if arg starts with a -
	if ( echo "${args[$x]}"|grep ^- >/dev/null );then
		argval=1
		arg="${args[$x]//-/}"
		val="${args[$((x+1))]}"
		#echo "$arg begins with a dash" >&2
		#echo "arg: $arg"
		#echo "val: $val"
		( [ "$arg" == "h" ] || [ "$arg" == "help" ] ) && showhelp


		# iterate list of arguments for a match
		unset found
		for i in $(seq 1 ${#myargs[@]});do

			# set individual arg settings
			unset argument argshort argname arghelp argcmd argtype
			argument="${myargs[$((i-1))]}"
			argshort="$(echo "$argument"|cut -d '|' -f 1)"
			argname="$(echo "$argument"|cut -d '|' -f 2)"
			arghelp="$(echo "$argument"|cut -d '|' -f 3)"
			argcmd="$(echo "$argument"|cut -d '|' -f 4-)"
			argtype="$(
					if [ ! "$argshort" ];then
						echo "positional"
					elif [[ "$argcmd" =~ '$val' ]];then
						echo "value"
					else
						echo "flag"
					fi
				)"

			# check if a match
			if ( [ "$arg" == "$argshort" ] || [ "$arg" == "$argname" ] );then
				found=yes
				#echo "Found: $arg Type: $argtype"

				# set $ARGS_argname value
				if [ "$argtype" == 'positional' ] || [ "$argtype" == 'value' ];then
					export ARGS_$argname="$val"
				elif [ "$argtype" == 'flag' ];then
					# Switches/Flags are Set to True under $ARGS_argname
					export ARGS_$argname="True"
				fi
				# execute runtext, exit on error
				source <(echo "${argcmd}") || ( r=$? && echo "$r $argname| $argcmd" && exit $r ) || exit $?
			fi
		done
		[ ! "$found" ] && echo "Unknown Argument: $arg" && exit 1
		#this is an argument name
	elif [ "$argval" ];then
		#this is an arguments value
		unset argval
	else
		#this is a positional
		#add to positionals array
		#echo "Adding to POSARGS: ${args[$x]}"
		POSARGS+=("${args[$x]}")
	fi
	x=$((x+1))
done


### Handle Positional Arguments
p=0
for i in $(seq 1 ${#myargs[@]});do
	argument="${myargs[$((i-1))]}"
	argshort="$(echo "$argument"|cut -d '|' -f 1)"
	if [ ! "$argshort" ];then
		#this defined arg is a positional
		argname="$(echo "$argument"|cut -d '|' -f 2)"
		arghelp="$(echo "$argument"|cut -d '|' -f 3)"
		argcmd="$(echo "$argument"|cut -d '|' -f 4-)"
		val="${POSARGS[$p]}"
		[ ! "$val" ] && echo "Argument Required: $argname: $arghelp" && exit 1
		export ARGS_$argname="$val"
		# execute runtext, exit on error
		source <(echo "${argcmd}") || ( r=$? && echo "$r: $argname: $argcmd" && exit $r ) || exit $?
		p=$((p+1))
	fi
done

     #\
   #==#\    (*)       ^                                 _      _    _
 #=====#\  +---+  /\ /#\  ^         #+++----+_+_+++--__===+++++ ###### #
## # i10[r1i1r1i3r1i7r1i10l4d1]r3i12.r1d3.i3.i5.d6.d2.i11.l1d13.r1d8. # ##
############################################################################
 ## ## ## ## ## ## ## ## ##  ▛▀▖ ▞▀▖ ▛▀▖ ▞▀▖ ▞▀▖ ## #   # #   # #   # #   #
  ### # ### # ### # ### # #  ▙▄▘ ▙▄▌ ▙▄▘ ▌▄▖ ▚▄  # # # # # # # # # # # # #
   # # # # # # # # # # # #   ▌ ▌ ▌ ▌ ▌▚  ▌ ▌ ▖ ▌  ### # ### # ### # ### #
    #   # #   # #   # #   #  ▀▀  ▘ ▘ ▘ ▘ ▝▀  ▝▀  ## ## ## ## ## ## ## ##
     ##################################################################
