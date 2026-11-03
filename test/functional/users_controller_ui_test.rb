require File.expand_path('../../test_helper', __FILE__)

class ExpertUiUsersControllerTest < Redmine::ControllerTest
  include ExpertUiTestHelper
  tests UsersController

  fixtures :users, :email_addresses, :user_preferences, :roles, :projects, :members,
           :member_roles, :auth_sources, :custom_fields, :custom_values, :groups_users

  def setup
    without_legacy_plugins
    @request.session[:user_id] = 1
  end

  def test_admin_sets_the_interval_of_a_user
    get :edit, :params => { :id => 2 }
    assert_select 'input[name="pref[refresh_interval]"]'

    put :update, :params => { :id => 2, :user => { :firstname => 'John' }, :pref => { :refresh_interval => '90' } }
    assert_redirected_to '/users/2/edit'
    assert_equal 90, User.find(2).pref.refresh_interval
  end
end
