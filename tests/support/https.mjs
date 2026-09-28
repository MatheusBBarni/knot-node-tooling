import { execFileSync } from "node:child_process";
import { mkdtemp, readFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import { removeWorkspace } from "./workspace.mjs";

export async function createTestCertificate(t) {
  const directory = await mkdtemp(path.join(tmpdir(), "knot-https-"));
  t.after(() => removeWorkspace(directory));
  const keyPath = path.join(directory, "key.pem");
  const certPath = path.join(directory, "cert.pem");
  execFileSync("openssl", [
    "req",
    "-x509",
    "-newkey",
    "rsa:2048",
    "-keyout",
    keyPath,
    "-out",
    certPath,
    "-days",
    "1",
    "-nodes",
    "-subj",
    "/CN=localhost",
    "-addext",
    "subjectAltName=DNS:localhost,IP:127.0.0.1",
  ], { stdio: "ignore" });

  return {
    key: await readFile(keyPath),
    cert: await readFile(certPath),
    certPath,
  };
}
