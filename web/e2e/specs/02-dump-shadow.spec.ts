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

  const targets: [string, string][] = [
    ['02-integrations', `${baseURL}/config/integrations/dashboard`],
    ['03-add-dialog', `${baseURL}/config/integrations/dashboard/add`],
    ['04-tuya-flow', `${baseURL}/_my_redirect/config_flow_start?domain=tuya`],
    ['05-speedtest-flow', `${baseURL}/_my_redirect/config_flow_start?domain=speedtestdotnet`],
    ['06-hacs-flow', `${baseURL}/_my_redirect/config_flow_start?domain=hacs`]
  ]
  for (const [name, url] of targets) {
    try { await page.goto(url, { waitUntil: 'domcontentloaded' }) } catch (e) { void e }
    await dump(page, name)
  }
})
