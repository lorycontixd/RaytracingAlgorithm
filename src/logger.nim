import std/[os, strutils, times]
import utils

type
  Level* {.pure.} = enum
    debug, info, warn, error, fatal

  Logger = object
    file: File

  MessageKind = enum
    write, update, stop

  Message = object
    case kind: MessageKind
    of write:
      module, text: string
    of update:
      loggers: seq[Logger]
    of stop:
      nil

var
  logLevel* = Level.info
  loggers = newSeq[Logger]()
  channel: Channel[Message]
  thread: Thread[void]


proc addLogger*(file: File) =
    ## AddLogger (file: File)
    ##      Registers a logger
    ##
    ## Parameters:
    ##      - file(File): stream to which the logger can write to (can be a filestream or a pipeline such as stdout/stderr)
    if size(loggers)<=0:
    let dir = joinPath(parentDir(getCurrentDir(), "examples", "logs"))
        if not existsDir(dir):
            createDir(dir)

    loggers.add Logger(file: file)
    channel.send Message(kind: update, loggers: loggers)


# --------  POSIX C functions for faster writing  ---------
proc fwriteUnlocked(buf: pointer, size, n: int, f: File): int {.
  importc: "fwrite_unlocked", noDecl.}

proc writeUnlocked(f: File, s: string) =
  if fwriteUnlocked(cstring(s), 1, s.len, f) != s.len:
    raise newException(IOError, "Cannot write string to file")

# --------------------------------------------------------

# Logging using threads
proc threadLog {.thread.} =
  var
    loggers = newSeq[Logger]()
    lastTime: Time
    timeStr = ""

  while true:
    let msg = recv channel
    case msg.kind
    of write:
      let newTime = getTime()
      if newTime != lastTime: # getDate + getClock are slowest -> Caching the time makes it faster. Caching format string only if seconds have changed (for multiple log calls)
        timeStr = getLocalTime(newTime).format "yyyy-MM-dd HH:mm:ss"
        lastTime = newTime

      let str = "[$#][$#]: $#\n" % [timeStr, msg.module, msg.text]

      for logger in loggers:
        logger.file.write(str)
        if channel.peek == 0:# Only flush when we're fast enough to keep up with the channel, otherwise let the OS buffer
          logger.file.flushFile
    of update:
      loggers = msg.loggers
    of stop:
      # Make sure we flush rest of text when we're done
      for logger in loggers:
        logger.file.flushFile
      break

proc stopLog {.noconv.} =
  channel.send(Message(kind: stop))
  joinThread(thread)
  close(channel)

  for logger in loggers:
    if logger.file notin [stdout, stderr]:
      close(logger.file)

var msg = Message(kind: write, module: "", text: "")
proc send(module: string, args: varargs[string]) =
  msg.module = module
  msg.text.setLen(0)
  for arg in args:
    msg.text.add(arg)
  channel.send(msg)

template log*(args: varargs[string, `$`]) =
  const module = instantiationInfo().filename[0 .. ^5]
  send(module, args)

template debug*(args: varargs[string, `$`]) =
  if logLevel <= Level.debug:
    const module = instantiationInfo().filename[0 .. ^5]
    send(module, args)

template info*(args: varargs[string, `$`]) =
  if logLevel <= Level.info:
    const module = instantiationInfo().filename[0 .. ^5]
    send(module, args)

template warn*(args: varargs[string, `$`]) =
  if logLevel <= Level.warn:
    const module = instantiationInfo().filename[0 .. ^5]
    send(module, args)

template error*(args: varargs[string, `$`]) =
  if logLevel <= Level.error:
    const module = instantiationInfo().filename[0 .. ^5]
    send(module, args)

template fatal*(args: varargs[string, `$`]) =
  if logLevel <= Level.fatal:
    const module = instantiationInfo().filename[0 .. ^5]
    send(module, args)

# Initialize module
open(channel)
thread.createThread(threadLog)
addQuitProc(stopLog)