import exceptions
import std/[parseopt, options]

#var args_string: string = cmdArgsToString() # read commands from command-line
#var p = initOptParser(args_string) # call parser

type
    Arg* = ref object of RootObj