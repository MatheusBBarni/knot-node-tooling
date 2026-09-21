import { spawn } from "node:child_process";

export function runProcess(command, args, options = {}) {
  const {
    cwd,
    env,
    timeoutMs = 30_000,
  } = options;

  return new Promise((resolve, reject) => {
    let stdout = "";
    let stderr = "";
    let settled = false;

    const child = spawn(command, args, {
      cwd,
      env,
      stdio: ["ignore", "pipe", "pipe"],
    });

    const timer = setTimeout(() => {
      child.kill("SIGKILL");
      finish(new Error(`${command} timed out after ${timeoutMs}ms`));
    }, timeoutMs);

    child.stdout.setEncoding("utf8");
    child.stderr.setEncoding("utf8");
    child.stdout.on("data", (chunk) => {
      stdout += chunk;
    });
    child.stderr.on("data", (chunk) => {
      stderr += chunk;
    });
    child.on("error", (error) => {
      finish(error);
    });
    child.on("close", (status, signal) => {
      finish(null, { status, signal, stdout, stderr });
    });

    function finish(error, result) {
      if (settled) {
        return;
      }
      settled = true;
      clearTimeout(timer);
      if (error) {
        error.stdout = stdout;
        error.stderr = stderr;
        reject(error);
        return;
      }
      resolve(result);
    }
  });
}
