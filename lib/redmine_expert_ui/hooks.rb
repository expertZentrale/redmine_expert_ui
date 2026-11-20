module RedmineExpertUi
  # View hooks. No Deface: the assets go into <head> on the few pages that use
  # them, the close button's markup into the issue page's details hook, and the
  # JavaScript moves it next to the other actions. The cancel guard has no
  # markup of its own: its script catches the core Cancel links.
  class Hooks < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context = {})
      controller = context[:controller]
      view = context[:hook_caller]
      return '' unless controller && view

      parts = []
      if (page = RedmineExpertUi.refresh_page(controller)) && RedmineExpertUi.auto_refresh_for?(User.current)
        parts << javascript_include_tag('expert_ui_auto_refresh', :plugin => 'redmine_expert_ui')
        parts << view.send(:render, :partial => 'expert_ui/auto_refresh', :locals => { :page => page, :user => User.current })
      elsif controller.controller_name == 'issues' && controller.action_name == 'show' &&
            RedmineExpertUi.active?('close_button')
        parts << javascript_include_tag('expert_ui_close_button', :plugin => 'redmine_expert_ui')
      end
      if RedmineExpertUi.cancel_guard_page?(controller) && RedmineExpertUi.cancel_guard_for?(context[:project])
        parts << javascript_include_tag('expert_ui_cancel_guard', :plugin => 'redmine_expert_ui')
        parts << view.send(:render, :partial => 'expert_ui/cancel_guard', :locals => { :user => User.current })
      end
      return '' if parts.empty?

      view.safe_join([stylesheet_link_tag('expert_ui', :plugin => 'redmine_expert_ui')] + parts)
    end

    def view_issues_show_details_bottom(context = {})
      issue = context[:issue]
      status = RedmineExpertUi.close_button_status(issue)
      return '' unless status

      context[:hook_caller].send(:render, :partial => 'expert_ui/close_button',
                                          :locals => { :issue => issue, :status => status })
    end

    def view_my_account_preferences(context = {})
      preference_fields(context)
    end

    def view_users_form_preferences(context = {})
      preference_fields(context)
    end

    private

    def preference_fields(context)
      [refresh_interval_field(context), theme_field(context), cancel_guard_field(context)].join
    end

    def cancel_guard_field(context)
      user = context[:user]
      return '' unless user && RedmineExpertUi.cancel_guard_in_use?

      context[:hook_caller].send(:render, :partial => 'expert_ui/cancel_guard_field', :locals => { :user => user })
    end

    def theme_field(context)
      user = context[:user]
      return '' unless user && RedmineExpertUi.active?('user_theme') && RedmineExpertUi.selectable_themes.any?

      context[:hook_caller].send(:render, :partial => 'expert_ui/theme_field', :locals => { :user => user })
    end

    def refresh_interval_field(context)
      user = context[:user]
      return '' unless user && RedmineExpertUi.active?('auto_refresh')

      context[:hook_caller].send(:render, :partial => 'expert_ui/refresh_interval_field',
                                          :locals => { :user => user })
    end
  end
end
