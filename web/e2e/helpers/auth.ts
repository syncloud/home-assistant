import { Page, expect } from '@playwright/test'

export async function login (page: Page, baseURL: string, username: string, password: string) {
  await page.goto(baseURL, { waitUntil: 'domcontentloaded' })
  const usernameField = page.locator('input[name="username"]')
  await expect(usernameField).toBeVisible({ timeout: 30_000 })
  await usernameField.fill(username)
  const passwordField = page.locator('input[name="password"]')
  await passwordField.fill(password)
  await passwordField.press('Enter')
  await expect(usernameField).toBeHidden({ timeout: 60_000 })
}
