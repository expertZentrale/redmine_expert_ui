# Changelog – redmine_expert_ui

> 🇬🇧 English version · [Deutsche Version](CHANGELOG.de.md)
>
> EN is authoritative — release notes are generated from this file.

## [Unreleased]

## [0.1.0] - 2026-11-03

### Added

- Close button on the issue page, next to *Edit* in both action bars. It sets a configurable closed
  status (default: the first closed status) and % Done 100, and saves the edit form, so a note
  typed into it goes along. Shown only while the issue is open, editable for the user and the
  workflow allows the status.
- Automatic refresh for the issue list and My page: a link that counts down and reloads the page,
  switched on per user and page. The reload waits while the user types, has rows selected, or has a
  dialog or the context menu open; background tabs reload once they are shown again.
- Refresh interval per user under *My account* (and in the admin's user form), at least
  10 seconds, with a default in the plugin settings.
- Uses the preferences `redmine_refresh` stored (interval, on/off per page), so users keep them.
- Each feature stays off while the plugin it replaces (`redmine_close_button`, `redmine_refresh`)
  is still installed; the settings page says so.
- UI in English, German, Spanish, French, Italian and Portuguese (Portugal, Brazil).
