# cookbook

Personal cookbook of copy-and-adapt code snippets for GCP, Terraform, SQL, Python, and shell.

These are **reference snippets**: you copy one, adapt it, and paste it, and each copy is expected to drift from the original. They are not a library. Code that needs to behave identically everywhere belongs in a versioned package instead (see [Graduation](#graduation)).

## Layout

Snippets are organized by domain, not by language:

```
cookbook/
├── gcp/          # gcloud, IAM, org/folder/project patterns
├── terraform/    # resource and module patterns, provider setup
├── sql/          # query patterns, window functions, DDL idioms
├── python/       # boilerplate, CLI setup, data-handling idioms
└── shell/        # bash one-liners and small scripts
```

Folders are added as they are needed, so not every folder may exist yet.

## Snippet conventions

Each snippet is a **small, runnable file** rather than a block in a long markdown page. Every file starts with a header comment like this:

```text
Purpose:       What this does, in one or two lines
When to use:   The situation it fits (and when not to use it)
Prerequisites: Tools, versions, permissions, env vars, APIs enabled
Last tested:   YYYY-MM-DD  (tool/provider versions)
Notes:         Gotchas, links to official docs
```

Write the header in the comment syntax for the file type (`#` for Python, shell, and Terraform; `--` for SQL).

Guidelines:

- **One idea per file.** Name the file for what it does, such as `bq-dedupe-latest-row.sql` or `gcs-bucket-uniform-access.tf`.
- **Keep it runnable.** Use placeholders like `PROJECT_ID` or `var.project_id` instead of real values.
- **No secrets.** No credentials, keys, tokens, or real account or org IDs.
- **Keep the last-tested date honest.** Snippets rot quietly. When you re-verify one, update the date. If you can't vouch for one anymore, mark it `STALE` in the header.

## Finding things

Search beats structure. From a local clone:

```bash
rg -i "service account" .          # search content
rg -l "Purpose:.*bucket" .         # search headers only
```

GitHub's repository search also works well for this.

## Graduation

A snippet graduates from this cookbook once it is being reused rather than adapted. The rule of thumb: if you've pasted it into three places and then had to fix it in all three, it's time.

When a snippet graduates:

1. Move it to its own repo as a proper package or module, with semantic versioning, tags, tests, and a CHANGELOG.
   - **Python:** a `pyproject.toml` package, installable from git with `pip install git+https://github.com/<owner>/<repo>@vX.Y.Z`
   - **Terraform:** a module repo, referenced with `source = "git::https://github.com/<owner>/<repo>.git?ref=vX.Y.Z"`
2. Replace the cookbook entry with a short pointer to the new repo and the pinned usage example.

## Adding a snippet

1. Pick the domain folder, or create it.
2. Add the file with the standard header.
3. Run it, or at least lint and validate it (for example `terraform validate`, `shellcheck`, or `ruff`).
4. Commit with a message describing what the snippet does.
