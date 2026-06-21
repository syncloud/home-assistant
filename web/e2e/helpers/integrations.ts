import { Page, expect } from '@playwright/test'

export async function assertIntegrationAvailable (page: Page, baseURL: string, term: string, label: string) {
  await page.goto(`${baseURL}/config/integrations/dashboard`, { waitUntil: 'domcontentloaded' })
  await page.getByRole('button', { name: /add integration/i }).click()
  const search = page.getByPlaceholder('Search for a brand name')
  await expect(search).toBeVisible({ timeout: 30_000 })
  await search.fill(term)
  await expect(page.getByText(label, { exact: true }).first()).toBeVisible({ timeout: 30_000 })
}
