# Copy only .md files from sodax-frontend/packages and its subdirectories into ./sdks folder, preserving directory structure
# The 'cp' command by default overwrites existing files.

find linked-repositories/sodax-frontend/packages -type f -name "*.md" -exec bash -c '
  for filepath; do
    relpath="${filepath#linked-repositories/sodax-frontend/packages/}"
    targetdir="./developers/packages/$(dirname "$relpath")"
    mkdir -p "$targetdir"
    # The following cp will overwrite any existing file with the same name
    cp "$filepath" "$targetdir/"
  done
' bash {} +
