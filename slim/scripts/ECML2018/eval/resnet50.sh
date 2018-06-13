#!/bin/bash
#
# Start script from slim/ directory!

# Where the checkpoint and logs will be saved to.
TRAIN_DIR=./tmp/resnetv1_50-model

# Name of Dataset
DATASET_NAME=imagenet

# Where the dataset is saved to.
DATASET_DIR=/data/tf

# QMaps
QMAP_DIR=${TRAIN_DIR}/QMaps
WEIGHT_QMAP=${QMAP_DIR}/optimal_sparse_weight.json
EXTR_QMAP=${QMAP_DIR}/optimal_sparse_extr.json

# Name of the Experiment
EXPERIMENT=resnet50_sparsity
EXP_FOLDER=experiment_results
EXP_FILE=./${EXP_FOLDER}/${EXPERIMENT}_$$.json

# Number of batches
NUM_BATCHES=-1

# Run evaluation.
python eval_image_classifier.py \
  --checkpoint_path=${TRAIN_DIR} \
  --eval_dir=/tmp/tf \
  --dataset_name=${DATASET_NAME} \
  --dataset_split_name=validation \
  --dataset_dir=${DATASET_DIR} \
  --model_name=resnet_v1_50 \
  --labels_offset=1 \
  --max_num_batches=${NUM_BATCHES} \
  --batch_size=128 \
  --output_file=${EXP_FILE} \
  --comment="type=baseline"

python eval_image_classifier.py \
  --checkpoint_path=${TRAIN_DIR} \
  --eval_dir=/tmp/tf \
  --dataset_name=${DATASET_NAME} \
  --dataset_split_name=validation \
  --dataset_dir=${DATASET_DIR} \
  --model_name=resnet_v1_50 \
  --labels_offset=1 \
  --max_num_batches=${NUM_BATCHES} \
  --batch_size=128 \
  --weight_qmap=${WEIGHT_QMAP} \
  --output_file=${EXP_FILE} \
  --comment="type=weight"

python eval_image_classifier.py \
  --checkpoint_path=${TRAIN_DIR} \
  --eval_dir=/tmp/tf \
  --dataset_name=${DATASET_NAME} \
  --dataset_split_name=validation \
  --dataset_dir=${DATASET_DIR} \
  --model_name=resnet_v1_50 \
  --labels_offset=1 \
  --max_num_batches=${NUM_BATCHES} \
  --batch_size=128 \
  --extr_qmap=${EXTR_QMAP} \
  --output_file=${EXP_FILE} \
  --comment="type=extr"
