function fs_replace_dir(src, dst) {
  const fs = require("fs");
  const path = require("path");
  const temp = `${dst}.knot-update-${process.pid}`;
  const backup = `${dst}.knot-backup-${process.pid}`;
  try {
    fs.rmSync(temp, { recursive: true, force: true });
    fs.rmSync(backup, { recursive: true, force: true });
    fs.mkdirSync(path.dirname(temp), { recursive: true });
    fs.cpSync(src, temp, { recursive: true, errorOnExist: false });
    const hadOld = fs.existsSync(dst);
    if (hadOld) {
      fs.renameSync(dst, backup);
    }
    try {
      if (process.env.KNOT_FAIL_REPLACE_STEP === "before-activate") {
        throw new Error("injected replace failure");
      }
      fs.renameSync(temp, dst);
    } catch (error) {
      if (hadOld) {
        fs.renameSync(backup, dst);
      }
      throw error;
    }
    if (hadOld) {
      fs.rmSync(backup, { recursive: true, force: true });
    }
    fs.rmSync(src, { recursive: true, force: true });
    return io_done({ $: "Unit" });
  } catch (error) {
    fs.rmSync(temp, { recursive: true, force: true });
    fs.rmSync(src, { recursive: true, force: true });
    return io_fail(-(error && error.errno ? error.errno : 1));
  }
}
