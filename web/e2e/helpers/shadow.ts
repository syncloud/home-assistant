import { Page } from '@playwright/test'

export async function dumpShadow (page: Page, keywords: string[] = []): Promise<string> {
  return await page.evaluate((kw: string[]) => {
    const lines: string[] = []
    const matches: string[] = []
    const lowKw = kw.map(k => k.toLowerCase()).filter(Boolean)

    function cssFor (el: Element): string {
      const tag = el.tagName.toLowerCase()
      if (el.id) return tag + '#' + ((window as any).CSS?.escape ? CSS.escape(el.id) : el.id)
      const parent = el.parentNode as any
      if (!parent || !parent.children) return tag
      const same = Array.prototype.filter.call(parent.children, (c: Element) => c.tagName === el.tagName) as Element[]
      if (same.length === 1) return tag
      return tag + ':nth-of-type(' + (same.indexOf(el) + 1) + ')'
    }
    function jsPath (el: Element): string {
      const segs: string[] = []
      let node: any = el
      while (node) {
        const root = node.getRootNode()
        const chain: string[] = []
        let cur: any = node
        while (cur && cur !== root) { chain.unshift(cssFor(cur)); cur = cur.parentElement }
        segs.unshift("querySelector('" + chain.join(' > ') + "')")
        if (root && root.host) { segs.unshift('shadowRoot'); node = root.host } else break
      }
      return 'document.' + segs.join('.')
    }
    function ownText (el: Element): string {
      let t = ''
      el.childNodes.forEach(n => { if (n.nodeType === 3) t += n.textContent || '' })
      return t.replace(/\s+/g, ' ').trim()
    }
    function attrs (el: Element): string {
      const keep = ['id', 'role', 'aria-label', 'name', 'placeholder', 'type', 'slot']
      const a: string[] = []
      for (const k of keep) { const v = el.getAttribute(k); if (v) a.push(k + '="' + v.slice(0, 80) + '"') }
      return a.length ? ' ' + a.join(' ') : ''
    }
    function walk (node: any, depth: number) {
      if (depth > 60) return
      const indent = '  '.repeat(depth)
      const kids = node.children ? Array.prototype.slice.call(node.children) : []
      for (const el of kids as Element[]) {
        const tag = el.tagName.toLowerCase()
        const t = ownText(el)
        lines.push(indent + '<' + tag + attrs(el) + '>' + (t ? ' "' + t.slice(0, 120) + '"' : ''))
        const hay = (t + ' ' + (el.getAttribute('aria-label') || '') + ' ' + (el.getAttribute('placeholder') || '')).toLowerCase()
        if (lowKw.some(k => hay.includes(k))) {
          matches.push('[' + tag + '] "' + t.slice(0, 60) + '" ' + attrs(el).trim() + '\n  ' + jsPath(el))
        }
        const sr = (el as any).shadowRoot
        if (sr) { lines.push(indent + '  #shadow-root(open)'); walk(sr, depth + 2) }
        walk(el, depth + 1)
      }
    }
    walk(document, 0)
    return 'URL: ' + location.href +
      '\n\n=== KEYWORD MATCHES (auto js path) ===\n' + matches.join('\n\n') +
      '\n\n=== FULL OPEN-SHADOW TREE ===\n' + lines.join('\n')
  }, keywords)
}
