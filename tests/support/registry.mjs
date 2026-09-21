import { createHash } from "node:crypto";
import http from "node:http";
import { gzipSync } from "node:zlib";

export function npmTarball(files, prefix = "package", symlinks = {}, modes = {}) {
  const parts = [];
  for (const [rel, content] of Object.entries(files)) {
    const data = Buffer.from(content);
    const name = `${prefix}/${rel}`.slice(0, 100);
    parts.push(tarHeader(name, data.length, modes[rel] ?? "0000644"));
    parts.push(data);
    const pad = (512 - (data.length % 512)) % 512;
    if (pad > 0) {
      parts.push(Buffer.alloc(pad));
    }
  }
  for (const [rel, target] of Object.entries(symlinks)) {
    const name = `${prefix}/${rel}`.slice(0, 100);
    parts.push(tarSymlinkHeader(name, target));
  }
  parts.push(Buffer.alloc(1024));
  return gzipSync(Buffer.concat(parts));
}

export function sriSha512(bytes) {
  return `sha512-${createHash("sha512").update(bytes).digest("base64")}`;
}

export function startRegistry(pkg) {
  const releases = pkg.versions ?? [{
    version: pkg.version,
    files: pkg.files,
    integrity: pkg.integrity,
  }];
  const artifacts = new Map();
  for (const rel of releases) {
    const tarball = npmTarball(rel.files, rel.tarPrefix ?? "package", rel.symlinks ?? {}, rel.modes ?? {});
    const tarballPath = `/${pkg.name}/-/${pkg.name}-${rel.version}.tgz`;
    artifacts.set(tarballPath, {
      tarball,
      integrity: rel.integrity ?? sriSha512(tarball),
      version: rel.version,
      engines: rel.engines,
    });
  }
  const distTags = pkg.distTags ?? { latest: releases[releases.length - 1].version };


  const server = http.createServer((req, res) => {
    if (req.method === "GET" && req.url === `/${pkg.name}`) {
      const versions = {};
      for (const [tarballPath, art] of artifacts) {
        versions[art.version] = {
          name: pkg.name,
          version: art.version,
          ...(art.engines ? { engines: art.engines } : {}),
          dist: {
            tarball: `http://127.0.0.1:${port}${tarballPath}`,
            integrity: art.integrity,
          },
        };
      }
      for (const version of pkg.extraVersions ?? []) {
        if (versions[version] === undefined) {
          versions[version] = {};
        }
      }
      const body = JSON.stringify({
        name: pkg.name,
        "dist-tags": distTags,

        versions,
      });
      res.writeHead(200, {
        "content-type": "application/vnd.npm.install-v1+json",
        "content-length": Buffer.byteLength(body),
      });
      res.end(body);
      return;
    }
    const art = artifacts.get(req.url);
    if (req.method === "GET" && art !== undefined) {
      res.writeHead(200, {
        "content-type": "application/octet-stream",
        "content-length": art.tarball.length,
      });
      res.end(art.tarball);
      return;
    }
    res.writeHead(404);
    res.end();
  });

  let port = 0;
  const listening = new Promise((resolve) => {
    server.listen(0, "127.0.0.1", () => {
      port = server.address().port;
      resolve();
    });
  });

  return {
    async url() {
      await listening;
      return `http://127.0.0.1:${port}`;
    },
    close() {
      return new Promise((resolve, reject) => {
        server.close((error) => {
          if (error) {
            reject(error);
            return;
          }
          resolve();
        });
      });
    },
  };
}

function tarHeader(name, size, mode = "0000644") {
  const buf = Buffer.alloc(512);
  buf.write(name);
  buf.write(`${mode}\0`, 100);
  buf.write("0000000\0", 108);
  buf.write("0000000\0", 116);
  buf.write(`${size.toString(8).padStart(11, "0")}\0`, 124);
  buf.write("00000000000\0", 136);
  buf.write("        ", 148);
  buf.write("0", 156);
  buf.write("ustar\0", 257);
  buf.write("00", 263);
  let sum = 0;
  for (const byte of buf) {
    sum += byte;
  }
  buf.write(`${sum.toString(8).padStart(6, "0")}\0 `, 148);
  return buf;
}

function tarSymlinkHeader(name, target) {
  const buf = Buffer.alloc(512);
  buf.write(name);
  buf.write("0000777\0", 100);
  buf.write("0000000\0", 108);
  buf.write("0000000\0", 116);
  buf.write(`${(0).toString(8).padStart(11, "0")}\0`, 124);
  buf.write("00000000000\0", 136);
  buf.write("        ", 148);
  buf.write("2", 156);
  buf.write(target.slice(0, 99), 157);
  buf.write("ustar\0", 257);
  buf.write("00", 263);
  let sum = 0;
  for (const byte of buf) {
    sum += byte;
  }
  buf.write(`${sum.toString(8).padStart(6, "0")}\0 `, 148);
  return buf;
}
