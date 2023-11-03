#!/usr/bin/env bash

# surreal start --auth --user root --pass root --bind 0.0.0.0:8000 memory
# surreal start --auth --user root --pass root --bind 0.0.0.0:8000 --allow-scripting  --allow-funcs --allow-net memory

# --log trace \
surreal start \
    --auth \
    --user root \
    --pass root \
    --allow-scripting \
    --allow-funcs \
    --allow-net \
    --log trace \
    --bind 0.0.0.0:8000 \
    memory
    ## file:mydatabase.db