# setup_github_pages.ps1
# One-shot: create the GitHub repo on your account, push the project, and
# enable GitHub Pages serving from /docs on the main branch.
#
# Prereqs: git + GitHub CLI (`gh`). If you don't have gh, install with:
#   winget install --id GitHub.cli   (or)   scoop install gh
# Then sign in once: `gh auth login`

param(
  [string]$RepoName = "BrightonRestaurantsMap",
  [string]$Visibility = "public"   # or "private"
)

$ErrorActionPreference = "Stop"

# Sanity checks
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw "git not found. Install Git for Windows." }
if (-not (Get-Command gh  -ErrorAction SilentlyContinue)) { throw "gh CLI not found. Install with: winget install --id GitHub.cli" }

# Clean any partially-initialised repo (the Cowork sandbox left one)
if (Test-Path ".git") {
  Write-Host "Removing existing .git/ ..."
  Remove-Item -Recurse -Force ".git"
}

# 1. Render the Quarto file → docs/index.html
if (Get-Command quarto -ErrorAction SilentlyContinue) {
  Write-Host "Rendering Quarto -> docs/index.html ..."
  quarto render
} else {
  Write-Warning "Quarto not on PATH — using the existing docs/index.html as-is."
}

# 2. Init repo and commit
git init -b main
git add -A
git -c user.email="$(git config --global user.email)" `
    -c user.name="$(git config --global user.name)"  `
    commit -m "Initial BRAVO 2026 map"

# 3. Create the repo on your GitHub account (gh prompts the first time for auth)
gh repo create $RepoName --$Visibility --source=. --remote=origin --push

# 4. Enable Pages serving from /docs on main
gh api `
  -X POST `
  -H "Accept: application/vnd.github+json" `
  "repos/{owner}/$RepoName/pages" `
  -f "source[branch]=main" -f "source[path]=/docs" 2>$null `
  || gh api `
       -X PUT `
       -H "Accept: application/vnd.github+json" `
       "repos/{owner}/$RepoName/pages" `
       -f "source[branch]=main" -f "source[path]=/docs"

# 5. Show the URL
$user = (gh api user --jq .login)
$url  = "https://$user.github.io/$RepoName/"
Write-Host ""
Write-Host "Done. Your map will appear at:"
Write-Host "  $url"
Write-Host "(allow ~1 min for Pages to build the first time)"
