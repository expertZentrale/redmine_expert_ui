# Redmine expert UI Plugin
#
# Copyright (C) 2026 Dennis Buehring
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version. See LICENSE for the full text.
#
# Small user-facing tweaks, one switch each: a close button on the issue page
# and an automatic refresh for the issue list and My page.
#
# Naming note: "expert" is the company name and is always written with a
# lowercase "e" in user-facing text. Code identifiers keep their normal casing.

require 'redmine'

require File.expand_path('../lib/redmine_expert_ui', __FILE__)
require File.expand_path('../lib/redmine_expert_ui/hooks', __FILE__)
require File.expand_path('../lib/redmine_expert_ui/patches/user_preference_patch', __FILE__)

Redmine::Plugin.register :redmine_expert_ui do
  name 'Redmine expert UI'
  author 'Dennis Buehring'
  description 'Small tweaks for everyday work: a close button on the issue page and an automatic refresh for the issue list and My page. Replaces redmine_close_button and redmine_refresh, without Deface.'
  version '0.1.0'
  url 'https://github.com/expertZentrale/redmine_expert_ui'
  requires_redmine '5.0'

  # A key missing from the stored hash (saved by an older release) reads like
  # its default here, see RedmineExpertUi.feature_switched_on?.
  settings :default => { 'close_button_enabled' => '1',
                         'close_button_status_id' => '',
                         'auto_refresh_enabled' => '1',
                         'auto_refresh_default_interval' => RedmineExpertUi::DEFAULT_INTERVAL.to_s },
           :partial => 'settings/expert_ui_settings'
end

RedmineExpertUi::Patches::UserPreferencePatch.apply!
