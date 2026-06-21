import { Page, ElementHandle } from '@playwright/test'

// Playwright port of syncloudlib SeleniumWrapper.element_by_js: evaluate a
// `document.querySelector(...).shadowRoot.querySelector(...)` chain (e.g. straight
// from DevTools "Copy JS path") and return the element. Unlike the selenium version
// it polls until the path resolves, so it tolerates HA's async shadow-DOM rendering.
export async function elementByJs (page: Page, js: string, timeout = 30_000): Promise<ElementHandle<HTMLElement>> {
  const guarded = `(() => { try { return (${js}) } catch (e) { return null } })()`
  await page.waitForFunction(`${guarded} != null`, undefined, { timeout, polling: 500 })
  const handle = await page.evaluateHandle(guarded)
  const el = handle.asElement() as ElementHandle<HTMLElement> | null
  if (!el) throw new Error('element_by_js did not resolve to an element: ' + js)
  await el.scrollIntoViewIfNeeded().catch(() => {})
  return el
}

export async function clickByJs (page: Page, js: string, timeout?: number): Promise<void> {
  await (await elementByJs(page, js, timeout)).click()
}

export async function textByJs (page: Page, js: string, timeout?: number): Promise<string> {
  const el = await elementByJs(page, js, timeout)
  return ((await el.textContent()) ?? '').trim()
}

export async function fillByJs (page: Page, js: string, value: string, timeout?: number): Promise<void> {
  await (await elementByJs(page, js, timeout)).fill(value)
}
