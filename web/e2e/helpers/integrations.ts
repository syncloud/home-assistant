import { Page, expect } from '@playwright/test'

export async function assertIntegrationAvailable (page: Page, baseURL: string, searchTerm: string, label: string) {
  await page.goto(`${baseURL}/config/integrations/dashboard`, { waitUntil: 'domcontentloaded' })

  const addButton = page.getByRole('button', { name: /add integration/i })
  await expect(addButton).toBeVisible({ timeout: 60_000 })
  await addButton.click()

  await page.waitForTimeout(1_000)
  await page.keyboard.type(searchTerm)

  await expect(page.getByText(label, { exact: true }).first()).toBeVisible({ timeout: 30_000 })
}
