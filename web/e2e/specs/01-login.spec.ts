import { test } from '@playwright/test'
import { login } from '../helpers/auth'
import { shoot } from '../helpers/screenshot'

const baseURL = `https://home-assistant.${process.env.PLAYWRIGHT_DOMAIN}`
const username = process.env.PLAYWRIGHT_USER!
const password = process.env.PLAYWRIGHT_PASSWORD!

test('logs in and lands on the dashboard', async ({ page }, info) => {
  await login(page, baseURL, username, password)
  await shoot(page, info, 'dashboard')
})
