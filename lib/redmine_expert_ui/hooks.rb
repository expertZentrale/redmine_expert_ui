module RedmineExpertUi
  # View hooks. No Deface: the assets go into <head> on the few pages that use
  # them, the close button's markup into the issue page's details hook, and the
  # JavaScript moves it next to the other actions.
  class Hooks < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context = {})
      controller = context[:controller]
      view = context[:hook_caller]
      return '' unless controller && view

      if (page = RedmineExpertUi.refresh_page(controller)) && RedmineExpertUi.auto_refresh_for?(User.current)
        assets('expert_ui_auto_refresh') +
          view.send(:render, :partial => 'expert_ui/auto_refresh', :locals => { :page => page, :user => User.current })
      elsif controller.controller_name == 'issues' && controller.action_name == 'show' &&
            RedmineExpertUi.active?('close_button')
        assets('expert_ui_close_button')
      else
        ''
      end
    end

    def view_issues_show_details_bottom(context = {})
      issue = context[:issue]
      status = RedmineExpertUi.close_button_status(issue)
      return '' unless status

      context[:hook_caller].send(:render, :partial => 'expert_ui/close_button',
                                          :locals => { :issue => issue, :status => status })
    end

    def view_my_account_preferences(context = {})
      refresh_interval_field(context)
    end

    def view_users_form_preferences(context = {})
      refresh_interval_field(context)
    end

    private

    def assets(script)
      stylesheet_link_tag('expert_ui', :plugin => 'redmine_expert_ui') +
        javascript_include_tag(script, :plugin => 'redmine_expert_ui')
    end

    def refresh_interval_field(context)
      user = context[:user]
      return '' unless user && RedmineExpertUi.active?('auto_refresh')

      context[:hook_caller].send(:render, :partial => 'expert_ui/refresh_interval_field',
                                          :locals => { :user => user })
    end
  end
end
