#!/usr/bin/env bash
pushd gen
bun run index.ts
popd
mix format