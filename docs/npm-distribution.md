# npm distribution

Date: 2026-09-21

Status: plan.
Nothing in this document is published.
The repository `package.json` stays `"private": true` until a tag meets the release gate below.
`knot --version` prints `0.0.1` in this release-preparation tree.

This document owns how the `knot` command is packaged and published to the public npm registry.
The package manager PRD still owns how Knot installs other people's packages.

## Command and package name

The command name is `knot`.
The unscoped npm package `knot` is already published.
`knot@0.0.9` went up on 2012-07-24 and describes itself as Knot Node, a client-side Node experiment.
npm's [username and package-name policy](https://docs.npmjs.com/policies/disputes) gives names out first-come, first-served.
The same policy says npm does not transfer a package because another project wants the name.
A trademark filing is the only dispute path npm documents, and this project does not have a trademark claim on that 2012 package.

The published wrapper is a scoped package.
Its `bin` field maps the command `knot` to the launcher, which is the mechanism npm documents for installing a command whose name differs from the package name.
Examples in this document use the `@matheusbbarni` npm scope.
The scope is the npm user or organization that owns the configured publish credentials.
The configured npm identity must own this scope before the first package is staged.
If it is an organization, register it when the first package is ready; npm treats an organization with no packages as squatting.

Users install it with npm and then run the command:

```text
npm install -g @matheusbbarni/knot
knot --version
```

A project-local install exposes the same command through `npx knot` and `node_modules/.bin/knot`.
`npx @matheusbbarni/knot` also works, because that form names the package.

Another global package can ship a `bin` named `knot`.
npm points the global `knot` shim at whichever package was installed or updated last.
The published README says that in one sentence.

## What is published

Each release is one wrapper package plus one package per platform binary.
Every package in that release uses the same version.
The wrapper depends on those platform packages with exact versions in `optionalDependencies`.
npm skips an optional dependency whose `os`, `cpu`, or `libc` does not match the host, and continues the install.
A required dependency with the same mismatch fails the install.
That is why the platform packages are optional.

The shape matches current registry practice for a native CLI.
`esbuild@0.28.2` lists one optional package per target and still runs `node install.js` from `postinstall` to download a binary when the optional package is absent.
`@biomejs/biome@2.5.14` lists the same kind of optional packages, sets `os`, `cpu`, and `libc` on each of them, and the published metadata has no install script.
Knot follows the Biome shape.
The bytes of the binary are the bytes inside the platform tarball, so the registry integrity check covers them.
A `postinstall` download would fetch different bytes, and it would be a lifecycle script.
Knot denies dependency lifecycle scripts unless the project approves them, so an install of Knot performed by Knot would skip that download.

The wrapper has no `postinstall`, `install`, or `prepare` script.
The platform packages have no scripts.
Neither package has a `binding.gyp`.

### Wrapper

Staging directory: `release/npm/knot/`.
This directory is built by the release job and is not the repository root.

```json
{
  "name": "@matheusbbarni/knot",
  "version": "0.0.1",
  "description": "Native JavaScript toolchain",
  "license": "Apache-2.0",
  "repository": {
    "type": "git",
    "url": "git+https://github.com/MatheusBBarni/knot-node-tooling.git"
  },
  "bin": {
    "knot": "bin/knot.js"
  },
  "engines": {
    "node": ">=18"
  },
  "optionalDependencies": {
    "@matheusbbarni/knot-darwin-arm64": "0.0.1",
    "@matheusbbarni/knot-linux-x64": "0.0.1"
  },
  "knot": {
    "bins": {
      "@matheusbbarni/knot-darwin-arm64": "<sha256 of that binary>",
      "@matheusbbarni/knot-linux-x64": "<sha256 of that binary>"
    }
  }
}
```

The release uses the SPDX expression `Apache-2.0`.
The repository includes `LICENSE`.
npm does not synthesize a license file from package metadata.
Staging copies the license and notices for anything linked into the binary from `src/host/` into every package.
The first publish waits until that expression, file, and notices exist.
`engines.node` is `>=18` because the launcher only needs `fs`, `path`, `os`, `crypto`, `module`, and `child_process`.
The repository root keeps `"node": "^24.0.0"` for the acceptance driver.
Copying the root engines field into the wrapper would make Knot refuse the package on Node 20 and 22.
Knot treats an unsatisfied `engines.node` as a hard error.
npm, by default, only warns.

The wrapper has no `main` and no `exports`.
The first release is a command.

`optionalDependencies` lists only platform packages that this version actually publishes.
The `knot.bins` map has one hex SHA-256 per listed package, computed from the file that was packed.

`bin/knot.js` starts with `#!/usr/bin/env node`.
npm's `bin` documentation states that the Windows `.cmd` shim runs the file with Node when the shebang is that line.
Without it, npm starts the file without Node.

### Platform package

Staging directory: `release/npm/knot-darwin-arm64/` and one sibling directory per target.

```json
{
  "name": "@matheusbbarni/knot-darwin-arm64",
  "version": "0.0.1",
  "description": "knot binary for darwin-arm64",
  "license": "Apache-2.0",
  "repository": {
    "type": "git",
    "url": "git+https://github.com/MatheusBBarni/knot-node-tooling.git"
  },
  "os": ["darwin"],
  "cpu": ["arm64"]
}
```

Linux glibc:

```json
{
  "name": "@matheusbbarni/knot-linux-x64",
  "os": ["linux"],
  "cpu": ["x64"],
  "libc": ["glibc"]
}
```

Linux musl uses a distinct package name and `"libc": ["musl"]`, the same split `@biomejs/cli-linux-x64-musl@2.5.14` publishes.
npm applies `libc` only when `os` is `linux`.

`os` and `cpu` are allow-lists of `process.platform` and `process.arch` tokens.
Knot's current matcher (`os_allowed` in `src/knot.bend`) treats the field as a match when the host token occurs in the metadata.
A block list such as `"!win32"` does not match a Darwin host under that check, so platform packages use allow-lists only.

The tarball contains `package.json`, the license, and one executable file named `bin/knot` (`bin/knot.exe` on Windows, once that target exists).
The executable bit is set before `npm pack`.
Knot already preserves executable mode when it extracts a tarball.
The file list contains no `.bend` source, no `src/host` sources, no tests, and no Bend compiler.

## Launcher

`bin/knot` in the repository remains the development wrapper.
It sets `KNOT_ARGC` and `KNOT_ARG_<n>`, then `exec`s `dist/knot.bin`.
The native `main` reads those variables because a Bend binary consumes argv for its own flags.
`release/npm/knot/bin/knot.js` implements the same environment contract and then starts the platform binary.

The launcher:

1. Reads `process.platform` and `process.arch`.
2. On Linux, chooses musl when a `/lib/ld-musl-*.so.1` loader is present, and glibc otherwise.
   A host where both loaders are present exits 1 and names both paths.
   The check is about the OS loader, not about which libc Node itself was built against.
3. Builds the platform package name from that triple.
4. Resolves `<package>/package.json` with `module.createRequire` from the launcher file.
   Node's resolver walks parent directories, so this finds the package whether npm hoisted it or nested it under the wrapper.
5. Reads the SHA-256 recorded for that package in the wrapper's `knot.bins`.
6. Hashes `bin/knot` (or `bin/knot.exe`) and compares.
   A mismatch prints `knot: binary integrity check failed` to stderr and exits 1.
7. Sets `KNOT_ARGC` and `KNOT_ARG_<n>` from `process.argv` after the node script path.
8. Starts the binary with `child_process.spawn`, `stdio` inherited, and no extra argv.
9. Forwards `SIGINT`, `SIGTERM`, and `SIGHUP` to the child.
10. Exits with the child's status.
    A signal death exits with `128` plus the signal number.

Node stays the parent process for the whole command.
The npm-installed `knot` therefore requires Node on `PATH` to start.
The native binary is the toolchain.
Node is the process that npm's `bin` shim uses to pick a platform file and replace argv with `KNOT_ARG_*`.
The published package does not embed Node, and the binary does not start a JavaScript runtime to compile or install.

Missing package, omitted optional dependencies (`npm install --omit=optional`), and an unpublished target all take the same path.
stderr names the package that was required and the platform triple that was detected.
The exit status is 127, matching `bin/knot` when `dist/knot.bin` is absent.

The launcher makes no network request and reads no registry credentials.

## Version

`knot --version` prints the version field of the repository `package.json`, with a trailing newline.
`tests/acceptance/cli/version.test.mjs` locks that to the literal printed by `dispatch_version` in `src/knot.bend`.
The release has one version string.
The release tag is created from a commit whose root `package.json`, the literal in `src/knot.bend`, and every staged npm `package.json` use the tag version without the leading `v`.
The release-preparation tree uses `0.0.1` and remains `private: true`.
Release preparation changes the root version and the Bend literal before creating `v0.0.1`; staging refuses a mismatch.
The first published version is `0.0.1`.
`0.0.1` is still a pre-1.0 release.
The bundler and the test runner are not part of it.

## Host programs the binary still uses

`scripts/build-knot` runs `bend src/knot.bend -o dist/knot.bin`.
The release job uses that command.
Bend 2.0.24 and the C compiler are build tools.
They are not files in the npm tarball.
The release runner installs Bend from `toolchain.json` and checks the SHA-256 recorded there before compiling.
`BEND_NO_TELEMETRY=1` is set for that install and build.
The shipped binary is a CPU build.
The release job does not pass a GPU flag.

The current host adapters are part of the runtime contract of that binary:

| Adapter | What the source does on a non-Apple host |
| --- | --- |
| `src/host/https_get.c` | `execlp("curl", ...)` for registry metadata |
| `src/host/http_get_file.c` | `execlp("curl", ...)` for tarball bytes |
| `src/host/gzip_inflate.c` | `execlp("gzip", ...)` |
| `src/host/tar_extract.c` | `dlopen` of `/usr/lib/libz.1.dylib` on Apple, `libz.so.1` otherwise |
| `src/host/hash_sha512_b64.c` | CommonCrypto on Apple. An embedded SHA-512 implementation elsewhere |

`knot --version` does not use those adapters.
`knot install` does.
A platform package is publishable when a clean image of that `os` / `cpu` / `libc` can run the focused one-package install acceptance test using the packed npm tarballs.
The clean image includes Node, because npm is the installer, plus the host tools that the shipped binary still requires at runtime.
Today those tools are `curl`, `gzip`, and zlib.
Apple provides CommonCrypto and `libz` on the OS.
Linux uses the embedded SHA-512 implementation.

The binary still shells out or `dlopen`s for HTTP, gzip, and zlib.
The published README lists those host tools for targets that need them.
The launcher does not try to install them.

## Targets

A target ships in a version only when a runner with that `process.platform`, `process.arch`, and libc passes the clean-image gate.
The binary is built on that runner.
A cross-compiled binary waits for a later version that boots it on the real target.

| Package | `os` | `cpu` | `libc` | First tag |
| --- | --- | --- | --- | --- |
| `@matheusbbarni/knot-darwin-arm64` | `darwin` | `arm64` | | Required. This is the current development machine class. |
| `@matheusbbarni/knot-linux-x64` | `linux` | `x64` | `glibc` | Required. The release workflow builds and validates this target on Ubuntu. |
| `@matheusbbarni/knot-darwin-x64` | `darwin` | `x64` | | Same mechanism. Ships when a matching runner passes. |
| `@matheusbbarni/knot-linux-arm64` | `linux` | `arm64` | `glibc` | Same mechanism. Ships when a matching runner passes. |
| `@matheusbbarni/knot-linux-x64-musl` | `linux` | `x64` | `musl` | Same, plus the musl loader check in the launcher. |
| `@matheusbbarni/knot-linux-arm64-musl` | `linux` | `arm64` | `musl` | Same as the other musl package. |
| `@matheusbbarni/knot-win32-x64` | `win32` | `x64` | | Later. The host adapters use `fork`, `execlp`, and Unix `dlopen` paths. |
| `@matheusbbarni/knot-win32-arm64` | `win32` | `arm64` | | Later, for the same reason. |

`0.0.1` is not tagged until `darwin-arm64` and `linux-x64` glibc are both in that list and both passed.
Other rows can be absent from `0.0.1`.
Their absence is the launcher's exit 127, with the package name it looked for.
The checked-in workflow builds both required targets on matching runners, verifies the Linux install and integrity gates, and assembles one wrapper with both platform packages.
The Linux x64 glibc target uses the pinned Linux Bend artifact and an embedded SHA-512 implementation.

## Installing Knot with Knot

npm is the installer this release accepts.
Knot can install the same manifests once three gaps are closed, and the release gate records them separately from the npm gate.

Knot already skips an optional package whose `os` or `cpu` allow-list does not contain the host.
It does not read `libc`.
On Linux it would install both the glibc and musl optional packages, because both allow `linux` and `x64`.
The launcher would still pick one.
`knot install` of `@matheusbbarni/knot` is equivalent to `npm install` of the same package after Knot honors `libc` the way npm does, and skips the other Linux package.

Knot materializes a package at `node_modules/.knot/<name>` and links optional dependencies through `link_children`, which symlinks `dest/node_modules/<name>`.
For a scoped name that path contains `@matheusbbarni/`.
The Knot-install gate uses a scoped wrapper and a scoped platform package.
The link step must create the scope directory before creating the symlink.

Knot links the wrapper `bin` as a relative symlink under `node_modules/.bin`.
The acceptance command is that symlink, run as `knot --version`, then a one-package install with the installed command.
`require.resolve` from the launcher file must find the platform package at the Knot child link.

## Publish

Publishing runs from GitHub Actions on `MatheusBBarni/knot-node-tooling`.
The workflow file is the only trusted publisher for every package in the release.
`npm trust github` is configured per package name, with `--file` set to that workflow.
Trusted publishing from a public repository attaches provenance.
npm's trusted-publisher documentation says provenance is generated automatically in that case.
Provenance records the repository, workflow, and commit.
It does not review the commit.
In September 2026 a trusted-publisher workflow for `@dforge-core/dforge-mcp` shipped a release whose provenance was valid because the attacker could push the branch that started the workflow (CloudSEK, reported 20 September 2026).

The workflow trigger is a tag matching `v*`.
The npm job's permissions are `id-token: write` and `contents: read`.
The GitHub release job's permissions are `contents: write` and `actions: read`.
That job does not get `id-token`.
Actions are pinned to commit SHAs.
`actions/setup-node` uses `package-manager-cache: false`.
A GitHub environment protects both jobs and requires a maintainer review.
The checked-in workflow currently supplies `NODE_AUTH_TOKEN` from `NPM_TOKEN`.
That is token-authenticated publishing, not evidence that npm OIDC trusted publishing is configured or that provenance will be attached.
Before the first publish, configure and exercise the intended authentication mode in npm.
The preferred mode is OIDC trusted publishing, which removes `NPM_TOKEN` and keeps `id-token: write`.
If a token is retained instead, the release gate must not describe that run as trusted publishing.
The workflow attempts `npm stage publish --access public` first.
Npm rejects that command for a package name that does not already exist.
The workflow falls back to `npm publish --access public` only for that package-not-found response.
If the bootstrap publish already succeeded and a release retry sees the same version, the exact `previously published versions` error is treated as success.
`actions/setup-node` sets `registry-url` to `https://registry.npmjs.org`, which makes npm read `NODE_AUTH_TOKEN`.
That variable is the Actions secret `NPM_TOKEN`.
The secret value is not written into the repository.
A maintainer approves staged versions with `npm stage approve` and 2FA.
Direct `npm publish` is restricted to the package bootstrap fallback.
Order inside one release:

1. Build each target on its runner and record the binary SHA-256.
2. Assemble platform staging directories and stage those packages.
3. Assemble the wrapper with exact `optionalDependencies` and `knot.bins`.
4. Stage the wrapper.
5. Approve every staged package of that version in one sitting, platform packages first and the wrapper last.
6. Upload each packed binary and `SHA256SUMS` to the GitHub release for the tag.

An unapproved platform package at that version is unused, because the wrapper is the only package that depends on it.
A wrapper is not approved if any platform package named in its `optionalDependencies` failed to stage.
npm does not publish this set as one transaction.
The approve step is what keeps the version aligned.

The release job uploads each raw binary and `SHA256SUMS` to the GitHub release for that tag.
The checksum is the SHA-256 stored in `knot.bins` for the file that was packed.
Those assets are the same bytes packed into the platform tarballs.
They are a way to compare a tarball.
They are not a second installer.

## Repository package

The release-preparation repository package keeps `"name": "knot"`, `"version": "0.0.1"`, and `"private": true`.
Release preparation changes the root version and Bend literal before creating the release tag; the release commit is no longer the development tree.
`private: true` makes `npm publish` from the repository root fail.
Release staging directories are the only directories that are published.
They are generated.
They are not committed with binaries inside them.

The launcher source that the release copies can live in the repository.
The compiled `bin/knot` for each platform cannot.

## Release gate

A tag is publishable when all of the following are true for every target included in that tag:

- The root version, the Bend literal, the tag, and every staged `package.json` are the same string.
- `npm pack --dry-run` from each staging directory lists the launcher or the one binary, `package.json`, and the license, and lists no Bend source and no test file.
- `npm install --ignore-scripts` of the staged wrapper tarball plus the matching platform tarball in a temporary project exits 0.
- `node_modules/.bin/knot --version` prints the version.
- The focused one-package install acceptance test passes when `KNOT` is that installed command, on a clean image of the target.
- Replacing one byte of the platform binary makes the launcher exit 1 before the binary starts.
- A target that was not packed produces exit 127 and names the missing package.
- The workflow used the configured npm authentication mode, used stage-first publishing with the package bootstrap fallback, and the checksum file matches the packed binaries.

The Knot-install gate in the previous section is required before this document calls Knot able to install Knot.
It is not required to publish the npm packages.

## Decisions

The npm package is scoped because the unscoped name is taken and npm does not hand that name over on request.
The command installed by `bin` is still `knot`.

Platform binaries are optional npm packages selected with `os`, `cpu`, and `libc`.
The wrapper does not download a binary.

The first tag includes Darwin arm64 and Linux x64 glibc, and includes further targets only after a matching runner passes the clean-image install.
Windows waits until the host adapters are portable.

The published engines field is `>=18`.
The acceptance driver stays on Node 24 in the repository root.

Provenance comes from trusted publishing.
A person still approves the staged version.
