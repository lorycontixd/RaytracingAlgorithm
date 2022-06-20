readonly SCENE_FILE="$1"
readonly WIDTH="$2"
readonly HEIGHT="$3"
readonly OUTPUTFILE="$4"
readonly S="$5"

readonly prefix="parallel/"
readonly seqNNN=$(printf "%04d" $S)
readonly filename=$OUTPUTFILE$seqNNN

echo ${S}
nim cpp -d:release ./RaytracingAlgorithm.nim && ./RaytracingAlgorithm.out render --filename=${SCENE_FILE} --width=${WIDTH} --height=${HEIGHT} --pcg_state=${S}  --output_filename=${filename}