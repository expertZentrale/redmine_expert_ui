# Copilot instructions – redmine_expert_ui

This file mirrors [`CLAUDE.md`](../CLAUDE.md). The two are intentional duplicates for
different tools — **keep them in sync when either changes.**

Small user-facing tweaks, one setting switch each: a close button on the issue page and an
automatic refresh for the issue list and My page. Replaces `redmine_close_button` and
`redmine_refresh` (and with it `redmine_base_deface` / the `deface` gem). No migrations. Settings
`close_button_enabled`, `close_button_status_id`, `auto_refresh_enabled`,
`auto_refresh_default_interval`.

This directory lives inside the parent `redmine-expert` deployment repo (`../../`). It is
**not** a Redmine checkout — Redmine only exists inside the Docker image. Run everything
from the parent repo root and read its `README.md` first (hard rule: never `docker exec`;
rebuild with `docker-compose -f docker-compose.yml up --build`).

## Layout

- `lib/redmine_expert_ui.rb` – settings readers and the rules: `active?(feature)` (switch on and
  the replaced plugin not installed, asked at request time because `redmine_refresh` registers
  after us), `close_status` (configured closed status or the first closed one),
  `close_button_status(issue, user)` (nil unless open, `attributes_editable?` and the workflow
  allows it), refresh interval and per-page on/off state (saved under a lock on the user's
  row, so two tabs toggling at once do not drop each other's change).
- `lib/redmine_expert_ui/hooks.rb` – `view_layouts_base_html_head` loads the stylesheet plus one
  script only where needed (`issues#show`: close button; `issues#index` / `my#page`: refresh, with
  its `<template>` link and JSON island `#expert-ui-auto-refresh-config`);
  `view_issues_show_details_bottom` renders the close button `<template>` and its JSON island;
  `view_my_account_preferences` / `view_users_form_preferences` render `pref[refresh_interval]`.
- `lib/redmine_expert_ui/patches/user_preference_patch.rb` – `safe_attributes 'refresh_interval'`
  plus accessors; the value lives in the serialized `others` hash under the key
  `redmine_refresh` used. So does `refresh_status` (controller name => bool).
- `app/controllers/expert_ui_auto_refresh_controller.rb` – `POST /expert_ui/auto_refresh` (session
  + CSRF header, JSON by Accept header: a `.json` URL would make Redmine ignore the session).
- `assets/javascripts/expert_ui_close_button.js` – moves the button into each `#content >
  .contextual` that has the edit link, before `.drdn`; a click sets `#issue_status_id` and
  `#issue_done_ratio` and triggers `submit` on `#issue-form` through jQuery (other handlers run).
- `assets/javascripts/expert_ui_auto_refresh.js` – countdown against a deadline, reload postponed
  while typing, rows selected, a dialog or the context menu open; hidden tabs wait until shown.

## Conventions

- Code comments English; UI via `config/locales/*.yml` in seven languages (`en`, `de`, `es`, `fr`,
  `it`, `pt`, `pt-BR`): every new or changed key goes into all of them, same order as `en.yml`, same
  `%{…}` placeholders (`test/unit/locale_files_test.rb` enforces it).
- Docs bilingual: `README.md` / `CHANGELOG.md` are authoritative, `README.de.md` /
  `CHANGELOG.de.md` are the German mirror — update both for every user-facing change.
- "expert" (the company) is always lowercase in user-facing text.
- Hash rockets, no frozen-string magic comments, `requires_redmine '5.0'`, plain `def ... end`
  (Ruby 2.7 on Redmine 5.1).
- Prefix every `app/` file and class `expert_ui…` / `ExpertUi…`: all plugins share one autoload
  path.
- No Deface, no copied core views or JS: hooks, `<template>` markup and JSON islands only. No inline
  `<script>` code.
- Icons: `sprite_icon` when the view responds to it (Redmine 6/7), the `icon icon-*` class on 5.1.
- A new feature gets its own `<feature>_enabled` switch; if it replaces a plugin, add it to
  `LEGACY_PLUGINS` so both can be deployed side by side.

## Tests

```bash
# from the parent repo root
docker-compose -f docker-compose.yml --profile test run --build --rm -e PLUGIN=redmine_expert_ui redmine-test
```

Tests stub `Redmine::Plugin.installed?` (`without_legacy_plugins`), so it does not matter whether
the image still ships the old plugins. Forgery protection is off in functional tests; the CSRF test
is an integration test that switches it on after signing in.

## CI

- `.github/workflows/ci.yml` – plugin tests against Redmine 5.1/6.0/6.1/7.0-stable on MariaDB.
- `.github/workflows/docker-image.yml` – official `redmine:*` images with the plugin mounted; signs
  in as admin (password set with `rails runner` in a one-off container) and checks that the issue
  list and My page link the script and stylesheet and that both are served.
- `.github/workflows/release.yml` – runs on `vX.Y.Z` tags only, see below.

## Git and releases

Branch as `type/short-desc` (Conventional-Commit types), PR into `main`, CI must pass.
Releases are tag driven: bump `version` in `init.rb` (single source of truth), add the
`## [<version>]` section to `CHANGELOG.md` (and its German mirror), commit, then
`git tag -a vX.Y.Z -m vX.Y.Z && git push origin vX.Y.Z`. `release.yml` verifies that the tag matches
the `init.rb` version, builds the notes from the matching CHANGELOG section and attaches the
`.zip` / `.tar.gz` archives to the GitHub release, then asks the plugin website
(`expertZentrale/redmine-plugins`) to rebuild via the `SITE_DISPATCH_TOKEN` secret (optional).

**Every release must also update `docs/redmine_org/`** (Textile, pasted into
<https://www.redmine.org/plugins/redmine_expert_ui>): a new
`docs/redmine_org/releases/<version>.textile` (`h3. redmine_expert_ui <version> — <date>`,
`h4. Added`/`Changed`/`Fixed`, closing with `h4. Upgrade notes`), and `description.textile` /
`installation.textile` when features or steps change. `docs/redmine_org/README.md` is the checklist.

`.github/copilot-instructions.md` mirrors this file — keep both in sync.
