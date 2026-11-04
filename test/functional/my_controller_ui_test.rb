require File.expand_path('../../test_helper', __FILE__)

class ExpertUiMyControllerTest < Redmine::ControllerTest
  include ExpertUiTestHelper
  tests MyController

  fixtures :users, :email_addresses, :user_preferences, :roles, :projects, :members,
           :member_roles, :issues, :issue_statuses, :trackers, :enumerations, :custom_fields

  def setup
    without_legacy_plugins
    @request.session[:user_id] = 2
  end

  def test_my_page_loads_the_automatic_refresh
    get :page
    assert_response :success
    config = JSON.parse(css_select('script#expert-ui-auto-refresh-config').first.text)
    assert_equal 'my', config['page']
    assert_equal false, config['enabled']
  end

  def test_account_shows_the_interval_field
    get :account
    assert_response :success
    assert_select 'input[name="pref[refresh_interval]"][type=number][min="10"]'
  end

  def test_account_saves_the_interval
    put :account, :params => { :user => { :firstname => 'John' }, :pref => { :refresh_interval => '45' } }
    assert_redirected_to '/my/account'
    assert_equal 45, User.find(2).pref.refresh_interval
  end

  def test_account_clears_the_interval
    User.find(2).pref.tap { |pref| pref.refresh_interval = '45' }.save!
    put :account, :params => { :user => { :firstname => 'John' }, :pref => { :refresh_interval => '' } }
    assert_nil User.find(2).pref.refresh_interval
  end

  def test_no_interval_field_while_switched_off
    with_ui_settings('auto_refresh_enabled' => '0') do
      get :account
    end
    assert_select 'input[name="pref[refresh_interval]"]', 0
  end
end
