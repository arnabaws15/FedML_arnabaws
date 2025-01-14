#!/usr/bin/env bash
set -e

BASE_DIR="$(dirname "$0")"
BASE_DIR="$(realpath "${BASE_DIR}/../")"
cd "${BASE_DIR}"

if [[ -z "${WANDB_MODE}" ]]; then
  export WANDB_MODE=disabled # remove this line if you want to use wandb
fi

NUM_GPU="$(python3 -c "import torch; print(torch.cuda.device_count())")"

MASTER_ADDR="${1:-"localhost"}"
MASTER_PORT="${2:-29500}"
NUM_NODES="${3:-1}"

echo "CUDA_VISIBLE_DEVICES=\"${CUDA_VISIBLE_DEVICES}\""
echo "${MASTER_ADDR}:${MASTER_PORT},${NUM_GPU},${NUM_NODES}"

# DeepSpeed setting
DS_ARGS=(
  --master_addr="${MASTER_ADDR}"
  --master_port="${MASTER_PORT}"
)
if [[ -z "${CUDA_VISIBLE_DEVICES}" ]]; then
  DS_ARGS+=(
    --num_nodes="${NUM_NODES}"
    --num_gpus="${NUM_GPU}"
  )
#else
#  # see https://github.com/microsoft/DeepSpeed/issues/662
#  DS_ARGS+=(
#    --include "${localhost}:${CUDA_VISIBLE_DEVICES}"
#  )
fi

deepspeed "${DS_ARGS[@]}" "${@:4}"
