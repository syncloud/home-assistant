import { Page, expect } from '@playwright/test'

export async function login (page: Page, baseURL: string, username: string, password: string) {
  const usernameField = page.locator('input[name="username"]')

  for (let attempt = 0; attempt < 30; attempt++) {
    try {
      await page.goto(baseURL, { waitUntil: 'domcontentloaded' })
      if (await usernameField.isVisible({ timeout: 10_000 }).catch(() => false)) break
    } catch {
      // app may be restarting after a snap install — retry
    }
    await page.waitForTimeout(10_000)
  }

  await expect(usernameField).toBeVisible({ timeout: 30_000 })
  await usernameField.fill(username)
  const passwordField = page.locator('input[name="password"]')
  await passwordField.fill(password)
  await passwordField.press('Enter')

  await expect(page.getByText('Welcome Home')).toBeVisible({ timeout: 90_000 })
}
