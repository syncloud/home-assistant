const fs = require("fs");
const path = require("path");

const buildDir = process.argv[2];
const webServer = path.join(
  buildDir,
  "app/node_modules/matter-server/dist/esm/server/WebServer.js"
);

const replacements = [
  [
    "      server.listen({ host, port: this.#port }, () => {",
    [
      '      const isUnixSocket = typeof host === "string" && host.startsWith("/");',
      "      const listenTarget = isUnixSocket ? { path: host } : { host, port: this.#port };",
      "      server.listen(listenTarget, () => {",
    ].join("\n"),
  ],
  [
    "        logger.notice(`Webserver listening on http://${displayHost}:${this.#port}`);",
    [
      "        logger.notice(",
      "          isUnixSocket",
      "            ? `Webserver listening on unix socket ${host}`",
      "            : `Webserver listening on http://${displayHost}:${this.#port}`",
      "        );",
    ].join("\n"),
  ],
];

let content = fs.readFileSync(webServer, "utf8");
for (const [old, replacement] of replacements) {
  if (!content.includes(old)) {
    console.error("pattern not found in " + webServer + ": " + old.trim());
    process.exit(1);
  }
  content = content.replace(old, replacement);
}

fs.writeFileSync(webServer, content);
console.log("patched matter.js server for unix socket transport");
