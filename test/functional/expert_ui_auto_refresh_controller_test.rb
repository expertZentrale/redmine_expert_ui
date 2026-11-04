require File.expand_path('../../test_helper', __FILE__)

class ExpertUiAutoRefreshControllerTest < Redmine::ControllerTest
  include ExpertUiTestHelper

  fixtures :users, :email_addresses, :user_preferences

  def setup
    without_legacy_plugins
    @request.session[:user_id] = 2
    # Like the link: JSON by Accept header, no .json suffix - a .json URL
    # makes Redmine ignore the session and ask for an API key.
    @request.headers['Accept'] = 'application/json'
  end

  def test_switches_on_and_off_per_page
    post :update, :params => { :page => 'issues', :enabled => '1' }
    assert_response :success
    assert_equal({ 'page' => 'issues', 'enabled' => true, 'interval' => RedmineExpertUi.default_interval },
                 JSON.parse(response.body))
    assert RedmineExpertUi.refresh_on?(User.find(2), 'issues')

    post :update, :params => { :page => 'issues', :enabled => '0' }
    assert_not RedmineExpertUi.refresh_on?(User.find(2), 'issues')
  end

  def test_unknown_page
    post :update, :params => { :page => 'admin', :enabled => '1' }
    assert_response :not_found
  end

  def test_requires_login
    @request.session[:user_id] = nil
    post :update, :params => { :page => 'issues', :enabled => '1' }
    assert_response :forbidden
  end

  def test_not_found_while_switched_off
    with_ui_settings('auto_refresh_enabled' => '0') do
      post :update, :params => { :page => 'issues', :enabled => '1' }
    end
    assert_response :not_found
  end
end
