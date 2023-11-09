#!/usr/bin/env bash

export RUST_BACKTRACE=1
# surreal start --auth --user root --pass root --bind 0.0.0.0:8000 memory
# surreal start --auth --user root --pass root --bind 0.0.0.0:8000 --allow-scripting  --allow-funcs --allow-net memory

# export RUST_BACKTRACE=1
# # --log trace \
surreal start \
    --auth \
    --user root \
    --pass root \
    --allow-scripting \
    --allow-funcs \
    --allow-net \
    --bind 0.0.0.0:8000 \
    memory
    ## file:mydatabase.db
