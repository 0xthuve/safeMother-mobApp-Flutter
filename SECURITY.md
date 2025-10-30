# Security & Secrets Remediation

This repository contained sensitive credentials in commits (API keys and a Google service account JSON). These secrets have been removed from the working tree. Follow the steps below immediately to fully remediate and rotate credentials.

## Immediate steps (recommended)

1. Rotate/revoke the exposed credentials right away:
   - Revoke/rotate the Groq API keys and any other API keys listed in the pull request.
   - Revoke the Google Cloud service account key shown in the repository and create a new one via Google Cloud Console -> IAM & Admin -> Service Accounts.
   - Rotate any other API keys (NewsAPI, email account passwords, etc.) that may have been leaked.

2. Do NOT store new secrets in the repository. Use one of:
   - Environment variables (local `.env` file which is listed in `.gitignore`)
   - A secrets manager (GitHub Secrets, GCP Secret Manager, Azure Key Vault, HashiCorp Vault, etc.)

## Remove sensitive files from the current branch (safe short-term)

To remove the sensitive files from the current working tree and current commit history (recommended to run from your workstation):

1. Remove tracked sensitive files from the index (this removes them from the next commit but not from history):

   # PowerShell (run in repo root)
   git rm --cached .env
   git rm --cached assets/still-cipher-468306-p2-aae0a6034688.json
   git commit -m "chore(secrets): remove tracked secrets from working tree"
   git push origin HEAD --force

2. Create a `.env.example` (already added) and instruct developers to use it.

## Scrub secrets from git history (recommended)

The only way to permanently remove secrets from all git history is to rewrite history. Recommended tools:

- git-filter-repo (recommended): https://github.com/newren/git-filter-repo
- BFG repo cleaner (alternative): https://rtyley.github.io/bfg-repo-cleaner/

Example using git-filter-repo (PowerShell):

1. Install git-filter-repo (see project docs). Then run (from a fresh clone):

   git clone --mirror <repo-url> repo-mirror.git
   cd repo-mirror.git
   git filter-repo --invert-paths --paths .env --paths assets/still-cipher-468306-p2-aae0a6034688.json
   git push --force

Example using BFG (alternative):

   # Create a mirror clone
   git clone --mirror <repo-url>
   # Use BFG to remove file
   bfg --delete-files ".env,assets/still-cipher-468306-p2-aae0a6034688.json" repo-name.git
   cd repo-name.git
   git reflog expire --expire=now --all && git gc --prune=now --aggressive
   git push --force

Notes:
- Rewriting history will change commit SHAs. Coordinate with your team. Prefer doing this on a repository with minimal collaborators or with full coordination.
- After rewriting, all contributors must re-clone or reset their local clones.

## Rotate credentials & verify

1. After scrubbing history, rotate every secret that was exposed.
2. Confirm the secrets no longer exist in the repo by running a secrets scan (GitGuardian or repo-wide grep).

## Follow-up

- Add pre-commit secret scanning (GitGuardian pre-commit integration or git-secrets) to block future leaks.
- Use CI secrets for builds and never commit plain text credentials.

If you want, I can prepare a small PowerShell script to automate the safe removal from the index and show the exact git-filter-repo commands tailored to your repo URL. I can also open a PR with these changes (non-destructive) and instructions for maintainers.
