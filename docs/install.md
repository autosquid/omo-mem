## Install omo-mem

### One-line install (latest stable release)

```bash
curl -fsSL https://raw.githubusercontent.com/autosquid/omo-mem/master/install.sh | bash
```

### Install pinned version

```bash
OMO_MEM_VERSION=v2.0.0 curl -fsSL https://raw.githubusercontent.com/autosquid/omo-mem/master/install.sh | bash
```

### Install from source checkout

```bash
git clone https://github.com/autosquid/omo-mem ~/workspace/omo-mem
cd ~/workspace/omo-mem && ./init.sh
```

### What installer does

- Resolves release version (`latest` by default, or `OMO_MEM_VERSION` if set)
- Downloads matching `init.sh` from GitHub
- Runs installer to create memory files and register plugin in opencode

### Verify plugin registration

```bash
cat ~/.config/opencode/opencode.json
```

You should see:

```json
"plugin": [
  "file:///Users/<you>/.config/opencode/plugins/omo-mem.js"
]
```

---

If omo-mem is useful, consider [starring the repo](https://github.com/autosquid/omo-mem) or [buying me a coffee](https://buymeacoffee.com/autosquid).
