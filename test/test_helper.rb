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
  def without_legacy_plugins
    Redmine::Plugin.stubs(:installed?).returns(false)
  end
end
