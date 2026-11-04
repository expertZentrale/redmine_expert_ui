require File.expand_path('../../test_helper', __FILE__)

class RedmineExpertUiTest < ActiveSupport::TestCase
  include ExpertUiTestHelper

  fixtures :projects, :users, :email_addresses, :roles, :members, :member_roles, :issues,
           :issue_statuses, :trackers, :projects_trackers, :enumerations, :enabled_modules,
           :workflows, :user_preferences

  def setup
    without_legacy_plugins
    User.current = nil
  end

  def test_close_status_defaults_to_the_first_closed_status
    with_ui_settings('close_button_status_id' => '') do
      assert_equal IssueStatus.where(:is_closed => true).sorted.first, RedmineExpertUi.close_status
    end
  end

  def test_close_status_uses_the_configured_closed_status
    rejected = IssueStatus.find(6)
    with_ui_settings('close_button_status_id' => rejected.id.to_s) do
      assert_equal rejected, RedmineExpertUi.close_status
    end
  end

  # An open status (or a deleted one) is never set by the button.
  def test_close_status_ignores_an_open_status
    with_ui_settings('close_button_status_id' => '2') do
      assert RedmineExpertUi.close_status.is_closed?
    end
  end

  def test_close_button_status_follows_the_workflow
    issue = Issue.find(1)
    jsmith = User.find(2)
    assert_equal RedmineExpertUi.close_status, RedmineExpertUi.close_button_status(issue, jsmith)

    WorkflowTransition.where(:old_status_id => issue.status_id, :new_status_id => RedmineExpertUi.close_status.id).delete_all
    assert_nil RedmineExpertUi.close_button_status(issue.reload, jsmith)
  end

  def test_no_close_button_on_closed_issues_or_for_anonymous
    assert_nil RedmineExpertUi.close_button_status(Issue.find(8), User.find(2))
    assert_nil RedmineExpertUi.close_button_status(Issue.find(1), User.anonymous)
  end

  def test_features_step_aside_while_the_old_plugin_is_installed
    Redmine::Plugin.stubs(:installed?).with(:redmine_close_button).returns(true)
    Redmine::Plugin.stubs(:installed?).with(:redmine_refresh).returns(false)
    assert_not RedmineExpertUi.active?('close_button')
    assert RedmineExpertUi.active?('auto_refresh')
    assert_nil RedmineExpertUi.close_button_status(Issue.find(1), User.find(2))
  end

  def test_switched_off_feature_is_inactive
    with_ui_settings('auto_refresh_enabled' => '0') do
      assert_not RedmineExpertUi.active?('auto_refresh')
    end
  end

  def test_missing_switch_reads_as_on
    with_ui_settings('close_button_enabled' => nil) do
      assert RedmineExpertUi.active?('close_button')
    end
  end

  def test_interval_uses_the_preference_then_the_default
    user = User.find(2)
    with_ui_settings('auto_refresh_default_interval' => '300') do
      assert_equal 300, RedmineExpertUi.interval_for(user)
      user.pref.refresh_interval = '45'
      assert_equal 45, RedmineExpertUi.interval_for(user)
    end
  end

  def test_default_interval_below_the_minimum_falls_back
    with_ui_settings('auto_refresh_default_interval' => '3') do
      assert_equal RedmineExpertUi::DEFAULT_INTERVAL, RedmineExpertUi.default_interval
    end
  end

  def test_refresh_interval_accessor
    pref = User.find(2).pref
    pref.refresh_interval = '5'
    assert_equal RedmineExpertUi::MIN_INTERVAL, pref.refresh_interval
    pref.refresh_interval = ' 90 '
    assert_equal 90, pref.refresh_interval
    pref.refresh_interval = ''
    assert_nil pref.refresh_interval
    assert_nil pref[:refresh_interval]
  end

  # The format redmine_refresh stored, so users keep their state.
  def test_refresh_state_is_kept_per_page_in_the_old_format
    user = User.find(2)
    user.pref[:refresh_status] = { 'issues' => true }
    user.pref.save!
    assert RedmineExpertUi.refresh_on?(user.reload, 'issues')
    assert_not RedmineExpertUi.refresh_on?(user, 'my')

    RedmineExpertUi.save_refresh_state(user, 'my', true)
    RedmineExpertUi.save_refresh_state(user, 'issues', false)
    status = User.find(2).pref[:refresh_status]
    assert_equal({ 'issues' => false, 'my' => true }, status)
  end

  # Two tabs toggling at once: a request holding an older copy of the
  # preferences must not drop the state the other request just saved.
  def test_refresh_state_survives_a_stale_copy_of_the_preferences
    User.find(2).pref.save!
    stale = User.find(2)
    stale.pref
    RedmineExpertUi.save_refresh_state(User.find(2), 'my', true)
    RedmineExpertUi.save_refresh_state(stale, 'issues', true)
    assert_equal({ 'issues' => true, 'my' => true }, User.find(2).pref[:refresh_status])
  end

  # save_refresh_state relies on Redmine saving the preference row on first
  # access, so the row it locks always exists and a toggle never adds another.
  def test_first_access_saves_the_preference_row
    UserPreference.where(:user_id => 2).delete_all
    assert User.find(2).pref.persisted?
    RedmineExpertUi.save_refresh_state(User.find(2), 'my', true)
    RedmineExpertUi.save_refresh_state(User.find(2), 'issues', true)
    assert_equal 1, UserPreference.where(:user_id => 2).count
    assert_equal({ 'issues' => true, 'my' => true }, User.find(2).pref[:refresh_status])
  end

  def test_refresh_pages
    assert_equal 'issues', RedmineExpertUi.refresh_page(stub(:controller_name => 'issues', :action_name => 'index'))
    assert_equal 'my', RedmineExpertUi.refresh_page(stub(:controller_name => 'my', :action_name => 'page'))
    assert_nil RedmineExpertUi.refresh_page(stub(:controller_name => 'issues', :action_name => 'show'))
  end
end
