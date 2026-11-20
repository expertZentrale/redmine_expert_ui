# Loads Redmine's own test helper - the tests require a Redmine environment
# (the Docker container or a Redmine checkout), they cannot run standalone.
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

module ExpertUiTestHelper
  def with_ui_settings(values)
    saved = Setting.plugin_redmine_expert_ui
    Setting.plugin_redmine_expert_ui = saved.merge(values.transform_keys(&:to_s))
    yield
  ensure
    Setting.plugin_redmine_expert_ui = saved
  end

  # The dev image may still ship redmine_close_button / redmine_refresh; the
  # tests decide themselves whether they count as installed.
  # A theme the test instance has installed (core ships some from 5.1 to 7.0).
  def any_theme
    Redmine::Themes.themes.first || skip('no theme installed')
  end

  def choose_theme(user, theme)
    user.pref.tap { |pref| pref.expert_ui_theme = theme && theme.id }.save!
  end

  def enable_cancel_guard(project_id = 1)
    EnabledModule.create!(:project_id => project_id, :name => RedmineExpertUi::CANCEL_GUARD_MODULE.to_s)
  end

  def choose_cancel_guard_style(user, style)
    user.pref.tap { |pref| pref.expert_ui_cancel_guard_style = style }.save!
  end

  def without_legacy_plugins
    Redmine::Plugin.stubs(:installed?).returns(false)
  end
end
