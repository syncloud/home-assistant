import { test, Page } from '@playwright/test'
import { login } from '../helpers/auth'
import { dumpShadow } from '../helpers/shadow'
import * as fs from 'node:fs'
import * as path from 'node:path'

const baseURL = `https://home-assistant.${process.env.PLAYWRIGHT_DOMAIN}`
const username = process.env.PLAYWRIGHT_USER!
const password = process.env.PLAYWRIGHT_PASSWORD!
const project = process.env.PLAYWRIGHT_PROJECT ?? 'desktop'
const outDir = path.join(process.env.PLAYWRIGHT_ARTIFACT_DIR ?? 'artifact', 'shadow', project)
const keywords = ['add integration', 'search', 'tuya', 'speedtest', 'hacs', 'integration', 'brand', 'settings', 'devices']

async function dump (page: Page, name: string) {
  try {
    fs.mkdirSync(outDir, { recursive: true })
    await page.waitForTimeout(3000)
    fs.writeFileSync(path.join(outDir, name + '.txt'), await dumpShadow(page, keywords))
    await page.screenshot({ path: path.join(outDir, name + '.png'), fullPage: true })
  } catch (e) {
    fs.writeFileSync(path.join(outDir, name + '.error.txt'), String(e))
  }
}

test('dump shadow trees for the integration flow', async ({ page }, info) => {
  test.setTimeout(900_000)
  try { await login(page, baseURL, username, password) } catch (e) { void e }
  await dump(page, '01-dashboard')

  try { await page.goto(`${baseURL}/config/integrations/dashboard`, { waitUntil: 'domcontentloaded' }) } catch (e) { void e }
  await dump(page, '02-integrations')

  for (const term of ['tuya', 'speedtest', 'hacs']) {
    try { await page.goto(`${baseURL}/config/integrations/dashboard`, { waitUntil: 'domcontentloaded' }) } catch (e) { void e }
    await page.waitForTimeout(2000)
    try { await page.getByRole('button', { name: /add integration/i }).click({ timeout: 30000 }) } catch (e) { void e }
    await page.waitForTimeout(2000)
    await dump(page, `03-add-open-${term}`)
    try { await page.keyboard.type(term); await page.waitForTimeout(2500) } catch (e) { void e }
    await dump(page, `04-search-${term}`)
  }
})
