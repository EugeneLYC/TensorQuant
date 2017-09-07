#!/bin/bash
#
# Dominik Loroch
# 
# Experiment: Explore batch_norm quantization with fixed point.
# 
# The intrinsic quantization of every batch_norm layer is swept.

MODEL=lenet

# Where the checkpoint and logs will be saved to.
TRAIN_DIR=./tmp/lenet-model

# Name of Dataset
DATASET_NAME=mnist

# Where the dataset is saved to.
DATASET_DIR=~/tmp/mnist

# number of validation samples
BATCHES=-1

# Name of the Experiment
EXPERIMENT=lenet_all
EXP_FOLDER=experiment_results
EXP_FILE=./${EXP_FOLDER}/${EXPERIMENT}.json

# input parameters
layers="conv2d,fully_connected
"

widths=$(seq 4 4 32)

# simulating and writing json file
#exec > ${EXP_FILE}
echo "PID:" $$
#exec >> ${EXP_FILE}
echo "######################"
echo "Start Experiment" ${EXPERIMENT}
date
echo "######################"
echo ""

# baseline
echo '[' > ${EXP_FILE}
python eval_image_classifier.py \
          --checkpoint_path=${TRAIN_DIR} \
          --eval_dir=/tmp/tf \
          --dataset_name=${DATASET_NAME} \
          --dataset_split_name=test \
          --dataset_dir=${DATASET_DIR} \
          --model_name=${MODEL} \
          --batch_size=10 \
          --max_num_batches=${BATCHES} \
          --output_file=${EXP_FILE}

for layer_type in $layers
do
for w in $widths
do
    prec=$(seq 0 2 $[$w-1])
    prec+=" $[$w-1]"
    for q in $prec
    do
    # intrinsic quantization.
    echo ',' >> ${EXP_FILE}
    python eval_image_classifier.py \
        --checkpoint_path=${TRAIN_DIR} \
          --eval_dir=/tmp/tf \
          --dataset_name=${DATASET_NAME} \
          --dataset_split_name=test \
          --dataset_dir=${DATASET_DIR} \
          --model_name=${MODEL} \
          --batch_size=10 \
          --max_num_batches=${BATCHES} \
          --output_file=${EXP_FILE} \
          --intr_quantizer=${w},${q},nearest \
          --intr_quantize_layers=$layer_type
    # extrinsic quantization
    echo ',' >> ${EXP_FILE}
    python eval_image_classifier.py \
        --checkpoint_path=${TRAIN_DIR} \
          --eval_dir=/tmp/tf \
          --dataset_name=${DATASET_NAME} \
          --dataset_split_name=test \
          --dataset_dir=${DATASET_DIR} \
          --model_name=${MODEL} \
          --batch_size=10 \
          --max_num_batches=${BATCHES} \
          --output_file=${EXP_FILE} \
          --extr_quantizer=${w},${q},nearest \
          --extr_quantize_layers=$layer_type
    done
done
done

echo ']' >> ${EXP_FILE}



echo "######################"
echo "Finished Experiment"
date
echo "######################"
