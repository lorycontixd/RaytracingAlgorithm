import std/[times, math]

const n: int64 = 10000000000

var start = cpuTime()
var sum: int64 = 0
for i in 0 || n:
  sum += 1
var endTime = cpuTime() - start
echo "Parallel for: ",endTime,"\t Sum= ",sum


start = cpuTime()
sum = 0
for i in 0..n:
  sum += 1
endTime = cpuTime() - start
echo "Normal for: ",endTime,"\t Sum= ",sum
