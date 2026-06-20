local name = 'home-assistant';
local version = '2026.6.4';
local nginx = '1.24.0';
local platform = '25.02';
local playwright = 'v1.59.1-jammy';
local store_publisher = 'stable-291';
local python = '3.12-slim-bookworm';
local distro_default = 'bookworm';
local distros = ['bookworm'];

local build(arch, test_ui) = [
  {
    kind: 'pipeline',
    type: 'docker',
    name: arch,
    platform: {
      os: 'linux',
      arch: arch,
    },
    steps: [
             {
               name: 'version',
               image: 'debian:bookworm-slim',
               commands: [
                 'echo $DRONE_BUILD_NUMBER > version',
               ],
             },
             {
               name: 'cli',
               image: 'golang:1.24',
               commands: [
                 'cd cli',
                 'CGO_ENABLED=0 go build -o ../build/snap/meta/hooks/install ./cmd/install',
                 'CGO_ENABLED=0 go build -o ../build/snap/meta/hooks/configure ./cmd/configure',
                 'CGO_ENABLED=0 go build -o ../build/snap/meta/hooks/pre-refresh ./cmd/pre-refresh',
                 'CGO_ENABLED=0 go build -o ../build/snap/meta/hooks/post-refresh ./cmd/post-refresh',
                 'CGO_ENABLED=0 go build -o ../build/snap/bin/cli ./cmd/cli',
               ],
             },
             {
               name: 'nginx',
               image: 'nginx:' + nginx,
               commands: [
                 './nginx/build.sh',
               ],
             },
             {
               name: 'nginx test',
               image: 'syncloud/platform-buster-' + arch + ':' + platform,
               commands: [
                 './nginx/test.sh',
               ],
             },

             {
               name: 'download',
               image: 'debian:bookworm-slim',
               commands: [
                 './download.sh',
               ],
             },
             {
               name: 'home assistant',
               image: 'homeassistant/home-assistant:' + version,
               commands: [
                 './home-assistant/build.sh',
               ],
             },
             {
               name: 'home assistant test',
               image: 'syncloud/platform-buster-' + arch + ':' + platform,
               commands: [
                 './home-assistant/test.sh',
               ],
             },
             {
               name: 'package',
               image: 'debian:bookworm-slim',
               commands: [
                 'VERSION=$(cat version)',
                 './package.sh ' + name + ' $VERSION ',
               ],
             },
           ] + [
             {
               name: 'test ' + distro,
               image: 'python:' + python,
               commands: [
                 'cd test',
                 './deps.sh',
                 'py.test -x -s test.py --distro=' + distro + ' --ver=$DRONE_BUILD_NUMBER --app=' + name,
               ],
             }
             for distro in distros

           ] + (if test_ui then [
                  {
                    name: 'test-ui-' + project,
                    image: 'mcr.microsoft.com/playwright:' + playwright,
                    commands: [
                      'PLAYWRIGHT_DOMAIN=' + distro_default + '.com ./web/e2e/ci-ui.sh ' + project,
                    ],
                  }
                  for project in ['desktop', 'mobile']
                ] else []) +
           (if arch == 'amd64' then [
              {
                name: 'test-upgrade',
                image: 'mcr.microsoft.com/playwright:' + playwright,
                commands: [
                  'PLAYWRIGHT_DOMAIN=' + distro_default + '.com ./web/e2e/ci-upgrade.sh',
                ],
              },
            ] else []) + [
      {
        name: 'publish',
        image: 'syncloud/store-publisher:' + store_publisher,
        environment: {
          SYNCLOUD_TOKEN: {
            from_secret: 'SYNCLOUD_TOKEN',
          },
        },
        command: ['snap', '-c', '${DRONE_BRANCH}'],
        when: {
          branch: ['master', 'stable'],
          event: ['push'],
        },
      },
      {
        name: 'artifact',
        image: 'appleboy/drone-scp:1.6.4',
        settings: {
          host: {
            from_secret: 'artifact_host',
          },
          username: 'artifact',
          key: {
            from_secret: 'artifact_key',
          },
          timeout: '2m',
          command_timeout: '2m',
          target: '/home/artifact/repo/' + name + '/${DRONE_BUILD_NUMBER}-' + arch,
          source: [
            'artifact/*',
          ],
          strip_components: 1,
        },
        when: {
          status: ['failure', 'success'],
        },
      },
    ],
    trigger: {
      event: [
        'push',
        'pull_request',
      ],
    },
    services: [
      {
        name: name + '.' + distro + '.com',
        image: 'syncloud/platform-' + distro + '-' + arch + ':' + platform,
        privileged: true,
        entrypoint: ['/bin/sh', '-c', "mkdir -p /etc/systemd/system/snapd.service.d && printf '[Service]\\nExecStartPost=/bin/sh -c \"/usr/bin/snap set system refresh.hold=2099-01-01T00:00:00Z\"\\n' > /etc/systemd/system/snapd.service.d/disable-refresh.conf && exec /sbin/init"],
        volumes: [
          {
            name: 'dbus',
            path: '/var/run/dbus',
          },
          {
            name: 'dev',
            path: '/dev',
          },
        ],
      }
      for distro in distros
    ],
    volumes: [
      {
        name: 'dbus',
        host: {
          path: '/var/run/dbus',
        },
      },
      {
        name: 'dev',
        host: {
          path: '/dev',
        },
      },
    ],
  },
];

build('amd64', true) +
build('arm64', false) +
build('arm', false)
