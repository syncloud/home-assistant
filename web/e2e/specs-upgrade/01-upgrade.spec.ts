import { test, expect } from '@playwright/test'
import { login } from '../helpers/auth'
import { installStoreVersion, upgradeToBuild } from '../helpers/device'
import { shoot } from '../helpers/screenshot'

const baseURL = `https://home-assistant.${process.env.PLAYWRIGHT_DOMAIN}`
const username = process.env.PLAYWRIGHT_USER!
const password = process.env.PLAYWRIGHT_PASSWORD!

test('upgrades from the store version and keeps working', async ({ page }, info) => {
  test.setTimeout(1_800_000)

  installStoreVersion()
  await expect(async () => {
    await login(page, baseURL, username, password)
  }).toPass({ timeout: 300_000, intervals: [5_000] })
  await shoot(page, info, 'store-version')

  upgradeToBuild()
  await expect(async () => {
    await login(page, baseURL, username, password)
  }).toPass({ timeout: 300_000, intervals: [5_000] })
  await shoot(page, info, 'after-upgrade')
})
