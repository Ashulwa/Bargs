# Bargs v1.1.1

Bargs is an Argument parsing Module for Bash      
similar to yargs for nodejs or argparse for python

---

## USAGE

1. build the myargs array:

```sh
myargs=(
	'shorthand|argname|helptext|runtext'
	'...'
	'...'
)
```

2. source this module file:

```sh
source ./path/to/bargs.sh
```

---

## DOCUMENTATION

each argument type is defined like so:
```
positional:    '|argname|help|runtext'
switch/flag:   'shorthand|argname|help|runtext'
value args:    'shorthand|argname|help|runtext "$val"'
```

### General Stuff
- all defined arguments will store their values in their own unique variable: $ARGS_argname
- switches/flags will simply store the string 'True' as their $ARGS_value
- positionals (defined or not) are stored in the "$POSARGS" array
- help is a string that is displayed in the help menu
- runtext is a string that will be executed if the argument is present

### Help Menu
- Naming your Script: define $script_name before sourcing
- Adding a Description: define $script_description before sourcing
- Adding a Usage Example: define $script_usage before sourcing

### Naming/Triggering
- shorthands and names do not use leading dashes when they are defined
- the shorthand form is triggered on the commandline by: -shorthand
- the fullname form is triggered on the commandline by: --argname

### Positionals
- positional arguments are defined by having an empty shorthand
- defined positionals become required components
- all positionals (defined or not) are stored within "$POSARGS" array
- they are stored in the order they are recieved

### Flags/Switches
- flags/switches are arguments that dont need a value
- they are defined by runtext that does not contain this exact string: $val
- they will execute their runtext, and set their $ARGS_argname value as the string 'true'

### Arguments that Hold a Supplied Value
- value type arguments, are arguments that hold a user supplied value
- they are defined by runtext that contains the string: $val

### Runtext String
- runtext is an optional string that will be executed when parsing
- the arguments value is accessible via "$val" within runtext
- positionals will execute after all other arg types

some Examples for runtext:

```
( '|name|help|echo "${val}"' ) <----|positional: will echo the arguments value when parsed
( 'sh|name|help|echo "${val}"' ) <--|value type: will echo the arguments value when parsed
( '|name|help|' ) <-----------------|empty runtext: valid for both switches/positionals
( 'sh|name|help|#$val' ) <----------|the value type equivalent of an empty runtext
```

---

```
     #\
   #==#\    (*)       ^                                 _      _    _
 #=====#\  +---+  /\ /#\  ^  2025   #+++----+_+_+++--__===+++++ ###### #
## # i10[r1i1r1i3r1i7r1i10l4d1]r3i12.r1d3.i3.i5.d6.d2.i11.l1d13.r1d8. # ##
############################################################################
 ## ## ## ## ## ## ## ## ##  ▛▀▖ ▞▀▖ ▛▀▖ ▞▀▖ ▞▀▖ ## #   # #   # #   # #   #
  ### # ### # ### # ### # #  ▙▄▘ ▙▄▌ ▙▄▘ ▌▄▖ ▚▄  # # # # # # # # # # # # #
   # # # # # # # # # # # #   ▌ ▌ ▌ ▌ ▌▚  ▌ ▌ ▖ ▌  ### # ### # ### # ### #
    #   # #   # #   # #   #  ▀▀  ▘ ▘ ▘ ▘ ▝▀  ▝▀  ## ## ## ## ## ## ## ##
     ##################################################################
```

#### Changelog
- 1.0.0: ?? wrote basic functionality, archived for a year or two
- 1.1.0: 07/30/25 found in archive, added Documentation, Made Public
- 1.1.1: 07/31/25 added an example script, added Documentation for script_name/script_description/script_usage, changed help menu a little bit
