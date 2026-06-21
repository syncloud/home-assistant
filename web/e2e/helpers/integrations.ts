import { Page, expect } from '@playwright/test'
import { elementByJs, fillByJs, textByJs } from './jsfinder'

const ADD_INTEGRATION =
  "document.querySelector('home-assistant').shadowRoot" +
  ".querySelector('home-assistant-main').shadowRoot" +
  ".querySelector('ha-drawer > partial-panel-resolver > ha-panel-config > ha-config-integrations > ha-config-integrations-dashboard').shadowRoot" +
  ".querySelector('hass-tabs-subpage > ha-button')"

const BRAND_SEARCH =
  "document.querySelector('home-assistant').shadowRoot" +
  ".querySelector('dialog-add-integration').shadowRoot" +
  ".querySelector('ha-dialog > ha-input-search').shadowRoot" +
  ".querySelector('wa-input').shadowRoot" +
  ".querySelector('input#input')"

const FIRST_RESULT =
  "document.querySelector('home-assistant').shadowRoot" +
  ".querySelector('dialog-add-integration').shadowRoot" +
  ".querySelector('ha-dialog > ha-list > lit-virtualizer > ha-integration-list-item').shadowRoot" +
  ".querySelector('span:nth-of-type(2)')"

export async function assertIntegrationAvailable (page: Page, baseURL: string, term: string, label: string) {
  await page.goto(`${baseURL}/config/integrations/dashboard`, { waitUntil: 'domcontentloaded' })
  const add = await elementByJs(page, ADD_INTEGRATION, 60_000)
  await add.click({ timeout: 30_000, force: true })
  await fillByJs(page, BRAND_SEARCH, term)
  await expect.poll(() => textByJs(page, FIRST_RESULT, 5_000).catch(() => ''), { timeout: 30_000, intervals: [1_000] }).toBe(label)
}
