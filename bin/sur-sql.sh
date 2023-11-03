#!/usr/bin/env bash

surreal sql --endpoint http://0.0.0.0:8000 \
            --username root \
            --password root \
            --pretty \
            --ns test \
            --db test⏎