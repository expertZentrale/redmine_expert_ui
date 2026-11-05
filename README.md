> 🇬🇧 English version · [Deutsche Version](README.de.md)

# Redmine expert UI

Small tweaks for everyday work in Redmine, each with its own switch:

- a **Close button** on the issue page, and
- an **automatic refresh** for the issue list and My page.

It replaces the plugins `redmine_close_button` and `redmine_refresh`, keeps every user's refresh
settings, and needs neither Deface nor any copied core code.
Works on **Redmine 5.1, 6.0, 6.1 and 7.0**.

## Close button

A **Close** button next to *Edit* in the issue page's action bars (top and bottom). One click sets
the status to the closed status chosen in the settings, sets % Done to 100 when that field is
editable, and saves. Anything typed into the edit form is saved with it, so a closing note goes in
the same entry.

The button only shows when it can work: the issue is open, the user may edit it, and the workflow
lets the user set that status. Without a configured status it uses the first closed status in
Redmine's order (*Administration » Issue statuses*).

## Automatic refresh

An **Automatic refresh** link at the top of the issue list and of My page. A click switches the
refresh on for that page: the link counts down (*Refresh in 87 s*) and reloads the page at zero.
Another click switches it off again. The choice is stored per user and per page.

The reload waits while it would destroy something. It holds off while:

- the user types in a field;
- rows are selected for a bulk action;
- a dialog or the context menu is open.

A tab in the background reloads only once it is shown again.

Each user sets their interval under *My account » Preferences* (at least 10 seconds; empty means
the default). Administrators can set it in the user form as well.

## Settings

*Administration » Plugins » Redmine expert UI » Configure*:

| Setting | Default | Meaning |
|---|---|---|
| Show the close button | on | Switches the close button on or off |
| Status set by the button | first closed status | Which closed status the button sets |
| Offer the automatic refresh | on | Switches the link and the interval field on or off |
| Default interval | 120 seconds | For users who have not set their own |

## Moving from redmine_close_button and redmine_refresh

Both can stay installed at first: while one of them is, the matching feature here stays off and
the settings page says so. To switch:

1. Install this plugin and restart. Nothing changes yet.
2. Remove `plugins/redmine_close_button` and `plugins/redmine_refresh` and restart. Also remove
   `plugins/redmine_base_deface` if nothing else needs it, and with it the `deface` gem.
3. Under the settings, pick the closed status the button should set. `redmine_close_button` always
   set the status with id 5.

`redmine_refresh` stored each user's interval and on/off state in the user preferences. This plugin
reads the same values, so every user keeps them.

## Languages

User interface in English, German, Spanish, French, Italian and Portuguese (Portugal and Brazil);
other languages fall back to English.

## Installation

```bash
cd /path/to/redmine/plugins
git clone https://github.com/expertZentrale/redmine_expert_ui.git
# restart Redmine
```

No migrations, no extra gems.

## Tests

```bash
bundle exec rake redmine:plugins:test NAME=redmine_expert_ui RAILS_ENV=test
```

CI runs them against Redmine 5.1, 6.0, 6.1 and 7.0 on MariaDB, against 5.1 and 7.0 on MySQL and
PostgreSQL as well. It also starts the official Redmine Docker images with the plugin mounted and
checks the issue list and My page.

## License

GNU General Public License v2 or later, see [LICENSE](LICENSE).
