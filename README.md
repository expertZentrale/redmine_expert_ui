> 🇬🇧 English version · [Deutsche Version](README.de.md)

# Redmine expert UI

Small tweaks for everyday work in Redmine, each with its own switch:

- a **Close button** on the issue page,
- an **automatic refresh** for the issue list and My page,
- a **theme per user**, so everyone picks their own look, and
- a **cancel guard**, switched on per project, that asks before *Cancel* throws away typed text.

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

## Theme per user

Redmine has one theme for everybody. With this feature each user picks their own under
*My account » Preferences » Theme*; administrators can set it in the user form as well. Stylesheets,
images, favicon, icons and the theme's JavaScript all follow the choice.

Users who choose nothing keep the theme set under *Administration » Settings » Display*, so
switching the feature on changes nothing until someone picks a theme. That makes it a way to offer
a new theme without moving everyone at once. The login page and other anonymous pages always use
the global theme.

In the plugin settings you tick which themes are on offer; with none ticked, every installed theme
is. A choice that is no longer installed or no longer on offer falls back to the global theme.

## Cancel guard

*Cancel* under the issue form, under a reply to a customer or under an edited note closes the form
without saving what was typed. One slip and a long answer is gone. The cancel guard steps in when a
text field of that form holds changed text, and asks first. Without typed text, *Cancel* works as
always.

It runs in the projects that enable the module **Cancel guard** (*Project » Settings » Modules*);
there is no global switch. The plugin settings set the default style, and every user can pick
their own under *My account » Preferences*:

| Style | What happens |
|---|---|
| Confirm | A dialog: *Keep writing* (focused, also Escape) or *Discard* |
| Dodge | The link jumps away once or twice, with a cheeky remark, then gives in |
| Slide to cancel | A slider takes the link's place; only sliding it all the way cancels |
| Pour out | The link turns into a full glass. Held down, it tips over and runs dry (about 2.5 seconds); let go early and it stands up again with the text kept |
| Press and hold | Cancel only after holding the link (or Enter/Space) for 1.5 seconds |
| Shredder | The text runs through a shredder over the field; *Stop!* saves it |
| Surprise me | One of the five playful styles, picked each time |

Escape or a click elsewhere always keeps the text. With *reduced motion* set in the operating
system, the animated styles (dodge, pour out, shredder) show the dialog instead. The guard works
with both helpdesk plugins, since their replies are written in the issue form's notes field.

## Settings

*Administration » Plugins » Redmine expert UI » Configure*:

| Setting | Default | Meaning |
|---|---|---|
| Show the close button | on | Switches the close button on or off |
| Status set by the button | first closed status | Which closed status the button sets |
| Offer the automatic refresh | on | Switches the link and the interval field on or off |
| Default interval | 120 seconds | For users who have not set their own |
| Let users choose their theme | on | Switches the theme field under My account on or off |
| Themes on offer | none ticked | The themes users may pick; none ticked means all installed themes |
| Cancel guard: default style | Confirm | The style for users who have not picked their own; the guard itself is switched on per project |

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
