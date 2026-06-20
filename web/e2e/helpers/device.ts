import { ssh, scpTo } from './ssh'

const app = 'home-assistant'

export function installStoreVersion () {
  ssh(`snap remove ${app}`, { throw: false, timeout: 600_000 })
  ssh(`snap install ${app}`, { timeout: 1_200_000 })
}

export function upgradeToBuild () {
  const snap = process.env.PLAYWRIGHT_SNAP
  if (!snap) throw new Error('PLAYWRIGHT_SNAP not set')
  scpTo(snap, `/tmp/${app}.snap`)
  ssh(`snap install --devmode /tmp/${app}.snap`, { timeout: 1_200_000 })
}
