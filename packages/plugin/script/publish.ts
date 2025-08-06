#!/usr/bin/env bun

const dir = new URL("..", import.meta.url).pathname
process.chdir(dir)

import { $ } from "bun"

const snapshot = process.env["OPENCODE_SNAPSHOT"] === "true"

await $`bun tsc`

// Skip npm publishing for fork - requires NPM_CONFIG_TOKEN
/*
if (snapshot) {
  await $`bun publish --tag snapshot --access public`
  await $`git checkout package.json`
}
if (!snapshot) {
  await $`bun publish --access public`
}
*/
