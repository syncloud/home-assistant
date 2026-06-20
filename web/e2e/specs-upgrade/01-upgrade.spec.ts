import { test } from '@playwright/test'
import { login } from '../helpers/auth'
import { installStoreVersion, upgradeToBuild } from '../helpers/device'
import { shoot } from '../helpers/screenshot'

const baseURL = `https://home-assistant.${process.env.PLAYWRIGHT_DOMAIN}`
const username = process.env.PLAYWRIGHT_USER!
const password = process.env.PLAYWRIGHT_PASSWORD!

test('upgrades from the store version and keeps working', async ({ page }, info) => {
  installStoreVersion()
  await login(page, baseURL, username, password)
  await shoot(page, info, 'store-version')

  upgradeToBuild()
  await login(page, baseURL, username, password)
  await shoot(page, info, 'after-upgrade')
})
