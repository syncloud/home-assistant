import { test, expect } from '@playwright/test'
import { login } from '../helpers/auth'
import { shoot } from '../helpers/screenshot'

const baseURL = `https://home-assistant.${process.env.PLAYWRIGHT_DOMAIN}`
const username = process.env.PLAYWRIGHT_USER!
const password = process.env.PLAYWRIGHT_PASSWORD!

test('logs in and lands on the dashboard', async ({ page }, info) => {
  test.setTimeout(600_000)
  await expect(async () => {
    await login(page, baseURL, username, password)
  }).toPass({ timeout: 300_000, intervals: [5_000] })
  await shoot(page, info, 'dashboard')
})
