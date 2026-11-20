require File.expand_path('../../test_helper', __FILE__)

class ExpertUiSettingsControllerTest < Redmine::ControllerTest
  include ExpertUiTestHelper
  tests SettingsController

  fixtures :users, :email_addresses, :user_preferences, :roles, :projects, :members, :member_roles,
           :issue_statuses, :enabled_modules

  def setup
    without_legacy_plugins
    @request.session[:user_id] = 1
  end

  def test_plugin_settings_offer_every_cancel_guard_style
    enable_cancel_guard(1)
    get :plugin, :params => { :id => 'redmine_expert_ui' }
    assert_response :success
    assert_select 'fieldset#expert-ui-cancel-guard-settings' do
      assert_select 'select[name="settings[cancel_guard_style]"] option', RedmineExpertUi::CANCEL_GUARD_STYLES.size
      assert_select 'select[name="settings[cancel_guard_style]"] option[selected][value="confirm"]'
    end
  end

  # Inside with_ui_settings, which puts the stored settings back afterwards:
  # the settings cache would otherwise carry the saved style into other tests.
  def test_plugin_settings_save_the_default_style
    with_ui_settings('cancel_guard_style' => 'confirm') do
      post :plugin, :params => { :id => 'redmine_expert_ui', :settings => { :cancel_guard_style => 'random' } }
      assert_redirected_to '/settings/plugin/redmine_expert_ui'
      assert_equal 'random', RedmineExpertUi.cancel_guard_default_style
    end
  end
end
