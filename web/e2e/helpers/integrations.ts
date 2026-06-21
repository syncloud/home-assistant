import { Page, expect } from '@playwright/test'

export async function assertIntegrationAvailable (page: Page, baseURL: string, term: string, label: string) {
  await page.goto(`${baseURL}/config/integrations/dashboard`, { waitUntil: 'domcontentloaded' })
  const add = page.getByRole('button', { name: /add integration/i })
  await expect(add).toBeVisible({ timeout: 60_000 })
  await add.click({ timeout: 30_000, force: true })
  const search = page.getByPlaceholder('Search for a brand name')
  await expect(search).toBeVisible({ timeout: 30_000 })
  await search.fill(term)
  await expect(page.getByText(label, { exact: true }).first()).toBeVisible({ timeout: 30_000 })
}
