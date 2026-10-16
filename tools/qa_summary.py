#!/usr/bin/env python3
"""Turns an xcodebuild test log into a short Markdown report (qa/summary.md)."""
import re
import sys

log_path, out_path, exit_code = sys.argv[1], sys.argv[2], sys.argv[3]
log = open(log_path, errors="replace").read().splitlines()

cases = re.compile(r"Test Case '-\[(\S+) (\S+)\]' (passed|failed) \(([\d.]+) seconds\)")
passed, failed = [], []
for line in log:
    m = cases.search(line)
    if m:
        (passed if m.group(3) == "passed" else failed).append(f"{m.group(1)}.{m.group(2)} ({m.group(4)}s)")

def clean(line):
    return re.sub(r"^.*?/kb-workout/", "", line.strip())

compiler_error = re.compile(r"\.swift:\d+(:\d+)?: error: |^error: |^xcodebuild: error")
errors = sorted({clean(l) for l in log if compiler_error.search(l)})
warnings = sorted({clean(l) for l in log if " warning: " in l and "/kb-workout/" in l})

with open(out_path, "w") as f:
    status = "PASSED" if exit_code == "0" and not failed else "FAILED"
    f.write(f"# QA {status}\n\nxcodebuild exit code: {exit_code}\n\n")
    f.write(f"## Tests: {len(passed)} passed, {len(failed)} failed\n\n")
    for name in failed:
        f.write(f"- FAILED {name}\n")
    f.write("\n## Errors\n\n" + ("\n".join(f"- {e}" for e in errors) or "None") + "\n")
    f.write("\n## Warnings in project code\n\n" + ("\n".join(f"- {w}" for w in warnings) or "None") + "\n")
    f.write("\n## Passed\n\n" + "\n".join(f"- {p}" for p in passed) + "\n")
print(open(out_path).read())
