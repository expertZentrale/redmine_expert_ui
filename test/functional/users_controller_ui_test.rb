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

  def test_admin_sets_the_theme_of_a_user
    get :edit, :params => { :id => 2 }
    assert_select 'select[name="pref[expert_ui_theme]"]'

    put :update, :params => { :id => 2, :user => { :firstname => 'John' }, :pref => { :expert_ui_theme => any_theme.id } }
    assert_redirected_to '/users/2/edit'
    assert_equal any_theme.id, User.find(2).pref.expert_ui_theme
  end

  def test_admin_sets_the_cancel_guard_style_of_a_user
    enable_cancel_guard(1)
    get :edit, :params => { :id => 2 }
    assert_select 'select[name="pref[expert_ui_cancel_guard_style]"]'

    put :update, :params => { :id => 2, :user => { :firstname => 'John' }, :pref => { :expert_ui_cancel_guard_style => 'shredder' } }
    assert_redirected_to '/users/2/edit'
    assert_equal 'shredder', User.find(2).pref.expert_ui_cancel_guard_style
  end
end
