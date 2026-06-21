import { Page, TestInfo } from '@playwright/test'

export async function shoot (page: Page, info: TestInfo, name: string) {
  await page.waitForLoadState('domcontentloaded').catch(() => {})
  await page.getByText('Loading data').waitFor({ state: 'hidden', timeout: 30_000 }).catch(() => {})
  await page.waitForTimeout(2_000)
  await page.screenshot({ path: info.outputPath(`${name}.png`), fullPage: true })
}
