# Changelog – redmine_expert_ui

> 🇬🇧 English version · [Deutsche Version](CHANGELOG.de.md)
>
> EN is authoritative — release notes are generated from this file.

## [Unreleased]

## [0.2.0] - 2026-11-20

### Added

- Theme per user: a *Theme* field under *My account* (and in the admin's user form). Stylesheets,
  images, favicon, icons and the theme's JavaScript follow the user's choice; users who choose
  nothing keep the global theme, as do anonymous pages such as the login page.
- Plugin settings for it: a switch, and a list of the themes on offer (none ticked: every installed
  theme). A choice that is no longer installed or on offer falls back to the global theme.
- Cancel guard: when *Cancel* under the issue form (also used for helpdesk replies) or under an
  edited note would throw away changed text, it asks first. Switched on per project with the module
  *Cancel guard*; no global switch. Styles: confirm (default), dodge, slide to cancel, pour out,
  press and hold, shredder and surprise me. The plugin settings set the default style, users pick
  their own under *My account*. With reduced motion, the animated styles show the dialog instead.

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
