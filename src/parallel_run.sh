#!/bin/bash
SCENE_FILE="scene1.txt"
S="54"
WIDTH="800"
HEIGHT="600"
FILENAME="tmpout"
OUTFILE="output"

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --scene)
      SCENE_FILE="$2"
      shift # past argument
      shift # past value
      ;;
    --width)
      WIDTH="$2"
      shift # past argument
      shift # past value
      ;;
    --height)
      HEIGHT="$2"
      shift # past argument
      shift # past value
      ;;
    --file_out)
      OUTFILE="$2"
      shift # past argument
      shift # past value
      ;;
    --default)
      DEFAULT=YES
      shift # past argument
      ;;
    *)    # unknown option
      POSITIONAL+=("$1") # save it in an array for later
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL[@]}" # restore positional parameters

# echo "parallel_exe.sh:"
echo "${SCENE_FILE}"
# echo "${ALG}"
# echo "${S}"
# echo "${RAYS_PER_PIXEL}"
# echo "${NUM_OF_RAYS}"
# echo "${DEPTH}"
# echo "${RUSSIAN_ROULETTE}"
# echo "${FILENAME}"

echo -e "Computing parallel render of 4 pictures:"
echo -e "...it could take a while...\n"
parallel --ungroup -j 4 ./parallel_render.sh $SCENE_FILE $WIDTH $HEIGHT $FILENAME '{}' ::: $(seq 0 3)
echo -e "\nParallel rendering finished."

echo -e "\nSumming pictures..."
# julia ./exe/parallel_sum.jl --file_in $FILENAME
nim cpp -d:release ./parallel_merge.nim && ./parallel_merge merge --inputfilename=$FILENAME --outputfile=$OUTFILE

# find "." -name $FILENAME"0*" -type f -delete
echo -e "\n The 4 pictures have been deleted."