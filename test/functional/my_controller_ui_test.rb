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

  # --- Theme per user ---

  def test_account_offers_the_themes
    with_settings :ui_theme => '' do
      get :account
    end
    assert_response :success
    assert_select 'select[name="pref[expert_ui_theme]"]' do
      assert_select 'option[value=""][selected]'
      assert_select 'option', Redmine::Themes.themes.size + 1
      assert_select "option[value=?]", any_theme.id
    end
  end

  def test_account_saves_the_theme
    put :account, :params => { :user => { :firstname => 'John' }, :pref => { :expert_ui_theme => any_theme.id } }
    assert_redirected_to '/my/account'
    assert_equal any_theme.id, User.find(2).pref.expert_ui_theme
  end

  def test_account_drops_an_unknown_theme
    choose_theme(User.find(2), any_theme)
    put :account, :params => { :user => { :firstname => 'John' }, :pref => { :expert_ui_theme => 'no-such-theme' } }
    assert_nil User.find(2).pref.expert_ui_theme
  end

  def test_no_theme_field_while_switched_off
    with_ui_settings('user_theme_enabled' => '0') do
      get :account
    end
    assert_select 'select[name="pref[expert_ui_theme]"]', 0
  end

  def test_pages_load_the_users_theme
    choose_theme(User.find(2), any_theme)
    with_settings :ui_theme => '' do
      get :page
    end
    assert_response :success
    assert_select "link[rel=stylesheet][href*=?]", "themes/#{any_theme.dir}/"
    assert_select "body.theme-#{any_theme.name.tr(' ', '_')}"
  end

  def test_pages_keep_the_global_theme_without_a_choice
    with_settings :ui_theme => '' do
      get :page
    end
    assert_select "link[rel=stylesheet][href*=?]", 'themes/', 0
    assert_select 'body[class*="theme-"]', 0

    with_settings :ui_theme => any_theme.id do
      get :page
    end
    assert_select "link[rel=stylesheet][href*=?]", "themes/#{any_theme.dir}/"
    assert_select "body.theme-#{any_theme.name.tr(' ', '_')}"
  end

  def test_switched_off_pages_ignore_the_choice
    choose_theme(User.find(2), any_theme)
    with_settings :ui_theme => '' do
      with_ui_settings('user_theme_enabled' => '0') do
        get :page
      end
    end
    assert_select "link[rel=stylesheet][href*=?]", 'themes/', 0
  end

  def test_account_offers_the_cancel_guard_style_once_a_project_uses_it
    get :account
    assert_select 'select[name="pref[expert_ui_cancel_guard_style]"]', 0

    enable_cancel_guard(1)
    with_ui_settings('cancel_guard_style' => 'dodge') do
      get :account
    end
    assert_response :success
    assert_select 'select[name="pref[expert_ui_cancel_guard_style]"]' do
      assert_select 'option', RedmineExpertUi::CANCEL_GUARD_STYLES.size + 1
      assert_select 'option[value=""]', :text => /#{::I18n.t(:label_expert_ui_cancel_guard_style_dodge)}/
    end
  end

  def test_account_saves_the_cancel_guard_style
    enable_cancel_guard(1)
    put :account, :params => { :user => { :firstname => 'John' }, :pref => { :expert_ui_cancel_guard_style => 'hold' } }
    assert_redirected_to '/my/account'
    assert_equal 'hold', User.find(2).pref.expert_ui_cancel_guard_style

    put :account, :params => { :user => { :firstname => 'John' }, :pref => { :expert_ui_cancel_guard_style => 'teleport' } }
    assert_nil User.find(2).pref.expert_ui_cancel_guard_style
  end
end
