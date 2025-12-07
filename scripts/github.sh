#!/usr/bin/env bash
# github_safe_push.sh
# Usage: ./github.sh <repo_name>
# Requires: gh CLI logged in, git installed
# Behaviour: respects .gitignore, auto-excludes files > 100MB and untracks tracked large files

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <repo_name>"
  exit 1
fi

REPO_NAME=$1
USER=$(gh api user --jq .login)
THRESHOLD_BYTES=$((100 * 1024 * 1024))  # 100 MB

# default exclusions you can edit
EXCLUDES=(
  "node_modules/"
  "*.log"
  "*.tmp"
  ".env"
  "secrets/"
  "backup/"
  # "check/"
  # "new/"
  "dir_bruteforce"
)

# ensure .gitignore exists
if [ ! -f .gitignore ]; then
  echo "Creating .gitignore..."
  touch .gitignore
fi

# add excludes to .gitignore if missing
for pat in "${EXCLUDES[@]}"; do
  if ! grep -Fxq "$pat" .gitignore; then
    echo "$pat" >> .gitignore
  fi
done

echo "Updated .gitignore with configured patterns."

# function to find file size in bytes (POSIX)
file_size() {
  # stat compatible across Linux & macOS
  if stat --version >/dev/null 2>&1; then
    stat -c%s "$1"
  else
    stat -f%z "$1"
  fi
}

# 1) Find untracked large files (that would get added) and add them to .gitignore
echo "Checking for untracked large files (>100MB)..."
mapfile -t untracked_files < <(git ls-files --others --exclude-standard -z | xargs -0 -n1 printf "%s\n" 2>/dev/null || true)

big_untracked=()
for f in "${untracked_files[@]}"; do
  [ -f "$f" ] || continue
  size=$(file_size "$f")
  if [ "$size" -gt "$THRESHOLD_BYTES" ]; then
    big_untracked+=("$f")
    # add rule to .gitignore (exact path)
    if ! grep -Fxq "$f" .gitignore; then
      echo "$f" >> .gitignore
    fi
  fi
done

if [ ${#big_untracked[@]} -gt 0 ]; then
  echo "Found untracked large files (will be added to .gitignore and NOT staged):"
  for bf in "${big_untracked[@]}"; do
    echo "  - $bf ($(du -h "$bf" | cut -f1))"
  done
  echo "If you want these in the repo, consider Git LFS (https://git-lfs.github.com)."
fi

# 2) Find tracked large files (>100MB) and untrack them (git rm --cached)
echo "Checking for tracked large files (>100MB)..."
mapfile -t tracked_files < <(git ls-files -z | xargs -0 -n1 printf "%s\n" 2>/dev/null || true)

big_tracked=()
for f in "${tracked_files[@]}"; do
  [ -f "$f" ] || continue
  size=$(file_size "$f")
  if [ "$size" -gt "$THRESHOLD_BYTES" ]; then
    big_tracked+=("$f")
  fi
done

if [ ${#big_tracked[@]} -gt 0 ]; then
  echo "Found tracked large files. They will be removed from the index (git rm --cached) and added to .gitignore:"
  for bf in "${big_tracked[@]}"; do
    echo "  - $bf ($(du -h "$bf" | cut -f1))"
    # add to .gitignore if not present
    if ! grep -Fxq "$bf" .gitignore; then
      echo "$bf" >> .gitignore
    fi
    git rm --cached --ignore-unmatch -r "$bf" || true
  done

  # If we just removed files that are present in the latest commit, amend the latest commit
  # Check if HEAD exists (repo initialized & has commits)
  if git rev-parse --verify HEAD >/dev/null 2>&1; then
    # If HEAD commit changed (i.e. index differs from HEAD) then amend
    if ! git diff --cached --quiet; then
      echo "Amending latest commit to remove large files from the commit..."
      git commit --amend --no-edit
    else
      echo "No staged changes after removing large files. Will create a commit later if needed."
    fi
  fi

  echo "Large tracked files removed from index. They still exist locally but are not in git index."
  echo "If those files are present in older commits (earlier than HEAD), you will need to rewrite history (BFG or git filter-repo)."
  echo "Example BFG usage to remove file 'dir_bruteforce':"
  echo "  bfg --delete-files dir_bruteforce"
  echo "See https://rtyley.github.io/bfg-repo-cleaner/ or git filter-repo docs."
fi

# 3) Initialize repo / set remote if needed (but don't create nested dir)
if gh repo view "$USER/$REPO_NAME" &>/dev/null; then
  echo "✅ Repo '$REPO_NAME' already exists. Using current directory..."
  if [ ! -d ".git" ]; then
    git init
    git branch -M main || true
    git remote add origin "https://github.com/$USER/$REPO_NAME.git"
  else
    # ensure remote exists and is set to user's repo (if not, set it)
    if ! git remote get-url origin >/dev/null 2>&1; then
      git remote add origin "https://github.com/$USER/$REPO_NAME.git"
    fi
  fi
else
  echo "🚀 Repo '$REPO_NAME' does not exist. Creating on GitHub..."
  gh repo create "$REPO_NAME" --private --confirm
  if [ ! -d ".git" ]; then
    git init
  fi
  git branch -M main || true
  git remote add origin "https://github.com/$USER/$REPO_NAME.git"
fi

# 4) Stage changes (git add . respects .gitignore)
git add .

# 5) Commit sensible message
if git diff --cached --quiet; then
  echo "⚠️ No changes to commit."
else
  COMMIT_MSG="Update: $(date '+%Y-%m-%d %H:%M:%S')"
  git commit -m "$COMMIT_MSG"
fi

# 6) Push
echo "Pushing to origin main..."
# ensure branch exists locally
git branch --show-current >/dev/null 2>&1 || git branch -M main
git push origin main || {
  echo "Push failed. If it failed due to large files already present in history, see the 'BFG' suggestion above."
  exit 1
}

echo "Done."

# cd ~/ivanti
# ~/scripts/./github.sh ivanti