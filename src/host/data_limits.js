function data_limits(spec) {
  const match = /^([1-9]\d*):([1-9]\d*)$/.exec(spec);
  if (!match) return io_fail(1, "invalid data limits");
  globalThis.__knotDataLimits = { depth: Number(match[1]), nodes: Number(match[2]) };
  return io_done(null);
}

function knotLimitDepth() {
  return globalThis.__knotDataLimits?.depth || 128;
}

function knotLimitNodes() {
  return globalThis.__knotDataLimits?.nodes || 1000000;
}
