require File.expand_path('../../test_helper', __FILE__)

class ExpertUiIssuesControllerTest < Redmine::ControllerTest
  include ExpertUiTestHelper
  tests IssuesController

  fixtures :projects, :users, :email_addresses, :roles, :members, :member_roles, :issues,
           :issue_statuses, :trackers, :projects_trackers, :enumerations, :enabled_modules,
           :workflows, :user_preferences, :versions, :issue_categories, :custom_fields,
           :custom_values, :custom_fields_projects, :custom_fields_trackers, :journals,
           :journal_details, :queries, :watchers, :attachments

  def setup
    without_legacy_plugins
    @request.session[:user_id] = 2
  end

  def test_show_renders_the_close_button_with_the_status
    get :show, :params => { :id => 1 }
    assert_response :success
    assert_select 'template.expert-ui-close-button-template'
    config = JSON.parse(css_select('script.expert-ui-close-button-config').first.text)
    assert_equal RedmineExpertUi.close_status.id, config['statusId']
    assert_select 'head script[src*="expert_ui_close_button"]'
    assert_select 'head script[src*="expert_ui_auto_refresh"]', 0
  end

  def test_no_close_button_on_a_closed_issue
    get :show, :params => { :id => 8 }
    assert_response :success
    assert_select 'template.expert-ui-close-button-template', 0
  end

  def test_no_close_button_without_the_transition
    WorkflowTransition.where(:new_status_id => RedmineExpertUi.close_status.id).delete_all
    get :show, :params => { :id => 1 }
    assert_select 'template.expert-ui-close-button-template', 0
  end

  def test_no_close_button_while_switched_off
    with_ui_settings('close_button_enabled' => '0') do
      get :show, :params => { :id => 1 }
    end
    assert_select 'template.expert-ui-close-button-template', 0
    assert_select 'head script[src*="expert_ui"]', 0
  end

  def test_no_close_button_for_anonymous
    @request.session[:user_id] = nil
    get :show, :params => { :id => 1 }
    assert_response :success
    assert_select 'template.expert-ui-close-button-template', 0
  end

  def test_issue_list_loads_the_automatic_refresh
    User.find(2).pref.update!(:others => { :refresh_status => { 'issues' => true }, :refresh_interval => 60 })
    get :index, :params => { :project_id => 1 }
    assert_response :success
    assert_select 'head script[src*="expert_ui_auto_refresh"]'
    assert_select 'head template#expert-ui-auto-refresh-template a.expert-ui-auto-refresh'
    config = JSON.parse(css_select('script#expert-ui-auto-refresh-config').first.text)
    assert_equal 'issues', config['page']
    assert_equal true, config['enabled']
    assert_equal 60, config['interval']
    assert_equal '/expert_ui/auto_refresh', config['url']
  end

  def test_no_automatic_refresh_for_anonymous
    @request.session[:user_id] = nil
    get :index
    assert_response :success
    assert_select 'script#expert-ui-auto-refresh-config', 0
  end

  def test_no_automatic_refresh_while_the_old_plugin_is_installed
    Redmine::Plugin.stubs(:installed?).with(:redmine_refresh).returns(true)
    Redmine::Plugin.stubs(:installed?).with(:redmine_close_button).returns(false)
    get :index
    assert_select 'script#expert-ui-auto-refresh-config', 0
  end

  def test_show_loads_the_cancel_guard_in_projects_with_its_module
    enable_cancel_guard(1)
    get :show, :params => { :id => 1 }
    assert_response :success
    assert_select 'head script[src*="expert_ui_cancel_guard"]', 1
    assert_select 'head script[src*="expert_ui_close_button"]', 1
    assert_select 'head link[rel=stylesheet][href*="/expert_ui"]', 1
    config = JSON.parse(css_select('script#expert-ui-cancel-guard-config').first.text)
    assert_equal 'confirm', config['style']
    assert_equal '/issues/1', config['issuePath']
    assert_equal ::I18n.t(:button_expert_ui_cancel_guard_keep), config['labels']['keep']
    assert_equal 3, config['labels']['dodge'].size
  end

  def test_no_cancel_guard_without_the_module
    get :show, :params => { :id => 1 }
    assert_response :success
    assert_select 'head script[src*="expert_ui_cancel_guard"]', 0
    assert_select 'script#expert-ui-cancel-guard-config', 0
  end

  def test_no_cancel_guard_in_other_projects
    enable_cancel_guard(2)
    get :show, :params => { :id => 1 }
    assert_select 'head script[src*="expert_ui_cancel_guard"]', 0
  end

  def test_cancel_guard_follows_the_users_style
    enable_cancel_guard(1)
    choose_cancel_guard_style(User.find(2), 'pour')
    get :show, :params => { :id => 1 }
    config = JSON.parse(css_select('script#expert-ui-cancel-guard-config').first.text)
    assert_equal 'pour', config['style']
  end

  def test_cancel_guard_on_the_edit_page_and_after_a_failed_save
    enable_cancel_guard(1)
    get :edit, :params => { :id => 1 }
    assert_response :success
    assert_select 'head script[src*="expert_ui_cancel_guard"]', 1

    put :update, :params => { :id => 1, :issue => { :subject => '', :notes => 'Typed text' } }
    assert_response :success
    assert_select 'head script[src*="expert_ui_cancel_guard"]', 1
    assert_select 'textarea#issue_notes', :text => /Typed text/
  end

  def test_the_cancel_guard_alone_loads_the_stylesheet_once
    enable_cancel_guard(1)
    with_ui_settings('close_button_enabled' => '0') do
      get :show, :params => { :id => 1 }
    end
    assert_select 'head script[src*="expert_ui_close_button"]', 0
    assert_select 'head script[src*="expert_ui_cancel_guard"]', 1
    assert_select 'head link[rel=stylesheet][href*="/expert_ui"]', 1
  end
end
