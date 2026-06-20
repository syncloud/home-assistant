import { test } from '@playwright/test'
import { login } from '../helpers/auth'
import { assertIntegrationAvailable } from '../helpers/integrations'
import { shoot } from '../helpers/screenshot'

const baseURL = `https://home-assistant.${process.env.PLAYWRIGHT_DOMAIN}`
const username = process.env.PLAYWRIGHT_USER!
const password = process.env.PLAYWRIGHT_PASSWORD!

test('bundled HACS custom component is available', async ({ page }, info) => {
  await login(page, baseURL, username, password)
  await assertIntegrationAvailable(page, baseURL, 'HACS', 'HACS')
  await shoot(page, info, 'hacs')
})
