# Syncing this project to the GitHub repo (`_CLEAN`)

The GitHub-linked repo is the sibling folder `Fiscal_Channel_Replication_CLEAN/` (it holds `.git`).
This project folder is the working copy. To update GitHub, mirror this folder's contents into
`_CLEAN`, preserving `_CLEAN/.git`.

Run in **Terminal** (not the assistant sandbox — needs real delete perms + git credentials):

```bash
SRC="/Users/andys/Desktop/University of Liechstenstein/The_Fiscal_Channels_of_Monetary _Policy/Fiscal_Channel_Replication/Fiscal_Channel_Replication"
DST="/Users/andys/Desktop/University of Liechstenstein/The_Fiscal_Channels_of_Monetary _Policy/Fiscal_Channel_Replication_CLEAN"

# Preview (nothing changes):
rsync -avn --delete --exclude='.git' --exclude='.gitignore' --exclude='.gitattributes' --exclude='.DS_Store' "$SRC/" "$DST/"

# Apply:
rsync -av  --delete --exclude='.git' --exclude='.gitignore' --exclude='.gitattributes' --exclude='.DS_Store' "$SRC/" "$DST/"

# Commit & push:
cd "$DST" && git add -A && git commit -m "Update replication" && git push
```

Notes:
- Trailing slashes on both paths are required (syncs *contents*).
- `--delete` removes files in `_CLEAN` no longer present here (mirrors exactly).
- Excludes keep `_CLEAN`'s git metadata intact.
- Largest file ~4.8 MB; well under GitHub's 100 MB limit (no LFS needed).
- `.gitignore` in `_CLEAN` is currently empty, so figures/data commit and README images render.
