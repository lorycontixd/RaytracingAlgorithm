import std/locks

const
  iters: int = 9
var
  thr: array[0..4, Thread[int]]
  L: Lock

proc threadFunc(index: int) {.thread.} =
  for i in 0..index-1:
    acquire(L) # lock stdout
    echo i
    release(L)

initLock(L)
let n = int(iters/thr.high)
let extra = iters mod thr.high
echo "n: ",n
echo "extra: ",extra
for j in 0..int(iters/thr.high)-1:
  for i in 0..high(thr):
    createThread(thr[i], threadFunc, i + j * high(thr))
  joinThreads(thr)

deinitLock(L) 