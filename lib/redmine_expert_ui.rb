# Shared helpers of the UI plugin: settings readers and the rules that decide
# where each feature shows up.
#
# Each feature has its own switch and steps aside while the plugin it replaces
# is still installed, so both can be deployed side by side and the old one
# removed afterwards.
module RedmineExpertUi
  PLUGIN_ID = :redmine_expert_ui
  FEATURES = %w(close_button auto_refresh).freeze
  # The plugin each feature replaces.
  LEGACY_PLUGINS = { 'close_button' => :redmine_close_button, 'auto_refresh' => :redmine_refresh }.freeze
  DEFAULT_INTERVAL = 120
  MIN_INTERVAL = 10
  # Pages with the automatic refresh, controller => action. The controller name
  # is also the key of the per-user on/off state in the user preferences
  # (pref[:refresh_status]), the format redmine_refresh used, so every user's
  # current choice carries over. So does pref[:refresh_interval].
  REFRESH_PAGES = { 'issues' => 'index', 'my' => 'page' }.freeze

  module_function

  def settings
    Setting.respond_to?(:plugin_redmine_expert_ui) ? (Setting.plugin_redmine_expert_ui || {}) : {}
  end

  # The switch as stored; missing (saved before the key existed) reads as on,
  # like the default.
  def feature_switched_on?(feature)
    value = settings["#{feature}_enabled"]
    value.nil? || value.to_s == '1'
  end

  def legacy_plugin(feature)
    LEGACY_PLUGINS[feature.to_s]
  end

  # Asked at request time: redmine_refresh sorts after us and registers later.
  def legacy_plugin_installed?(feature)
    Redmine::Plugin.installed?(legacy_plugin(feature))
  end

  def active?(feature)
    feature_switched_on?(feature) && !legacy_plugin_installed?(feature)
  end

  # --- Close button ---

  def closed_statuses
    IssueStatus.where(:is_closed => true).sorted
  end

  # The configured status while it exists and closes issues, otherwise the
  # first closed status in Redmine's order.
  def close_status
    id = settings['close_button_status_id'].to_s
    status = closed_statuses.find_by(:id => id) if id.present?
    status || closed_statuses.first
  end

  # The status the close button would set on this issue for this user, or nil
  # when there is no button: issue already closed, form not editable for the
  # user, or the workflow does not allow the transition.
  def close_button_status(issue, user = User.current)
    return nil unless active?('close_button')
    return nil if issue.nil? || issue.new_record? || issue.closed?
    return nil unless issue.attributes_editable?(user)

    status = close_status
    status if status && issue.new_statuses_allowed_to(user).include?(status)
  end

  # --- Automatic refresh ---

  # 'issues' / 'my' when the controller renders a page with the refresh link.
  def refresh_page(controller)
    return nil unless controller.respond_to?(:controller_name) && controller.respond_to?(:action_name)

    page = controller.controller_name.to_s
    page if REFRESH_PAGES[page] == controller.action_name.to_s
  end

  def auto_refresh_for?(user)
    active?('auto_refresh') && user.logged?
  end

  def default_interval
    value = settings['auto_refresh_default_interval'].to_i
    value >= MIN_INTERVAL ? value : DEFAULT_INTERVAL
  end

  # The user's own interval (My account) or the default.
  def interval_for(user)
    value = user.pref[:refresh_interval].to_i
    value >= MIN_INTERVAL ? value : default_interval
  end

  def refresh_on?(user, page)
    status = user.pref[:refresh_status]
    status.is_a?(Hash) && status[page.to_s].to_s == 'true'
  end

  # The state of every page sits in one serialized hash, so two tabs toggling
  # at once could each read the old hash and the later save would drop the
  # other page's change. Locking the user's row serialises their toggles, and
  # the preference is re-read under that lock. User#pref normally saves a new
  # preference on first access already; a request still holding an unsaved one
  # looks the row up under the lock, so first toggles never add a second row
  # (user_id is not unique in that table).
  def save_refresh_state(user, page, on)
    UserPreference.transaction do
      User.where(:id => user.id).lock.pluck(:id)
      pref = user.pref
      pref = pref.persisted? ? pref.reload : (UserPreference.find_by(:user_id => user.id) || pref)
      status = pref[:refresh_status].is_a?(Hash) ? pref[:refresh_status].dup : {}
      status[page.to_s] = on ? true : false
      pref[:refresh_status] = status
      pref.save
    end
  end
end
