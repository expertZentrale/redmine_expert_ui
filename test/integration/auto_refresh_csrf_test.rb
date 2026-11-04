require File.expand_path('../../test_helper', __FILE__)

# The toggle changes a preference, so it must not work without the page's CSRF
# token (functional tests switch forgery protection off).
class ExpertUiAutoRefreshCsrfTest < Redmine::IntegrationTest
  include ExpertUiTestHelper

  fixtures :users, :email_addresses, :user_preferences

  def setup
    without_legacy_plugins
    @forgery = ActionController::Base.allow_forgery_protection
  end

  def teardown
    ActionController::Base.allow_forgery_protection = @forgery
  end

  def test_rejects_a_post_without_token
    log_user('jsmith', 'jsmith')
    ActionController::Base.allow_forgery_protection = true
    post '/expert_ui/auto_refresh', :params => { :page => 'issues', :enabled => '1' },
                                    :headers => { 'Accept' => 'application/json' }
    assert_response 422
    assert_not RedmineExpertUi.refresh_on?(User.find(2), 'issues')
  end
end
