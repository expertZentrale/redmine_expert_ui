module RedmineExpertUi
  module Patches
    # Core asks Redmine::Themes::Helper#current_theme for every themed asset
    # (stylesheets, images, favicon, icon sprites, theme.js) and reads
    # Setting.ui_theme there. Answering with the user's own theme is all it
    # takes to theme a page per user. Only the body's "theme-..." class reads
    # the setting directly, so that one is corrected as well.
    #
    # The methods are redefined in place rather than prepended: on Ruby 2.7
    # (Redmine 5.1) a module prepended to a module does not reach the classes
    # that already include it.
    module ThemeHelperPatch
      def self.apply!
        return if Redmine::Themes::Helper.method_defined?(:current_theme_without_expert_ui)

        Redmine::Themes::Helper.module_eval do
          alias_method :current_theme_without_expert_ui, :current_theme

          def current_theme
            unless instance_variable_defined?(:@current_theme)
              @current_theme = RedmineExpertUi.theme_for(User.current)
            end
            @current_theme
          end
        end

        ApplicationHelper.module_eval do
          alias_method :body_css_classes_without_expert_ui, :body_css_classes

          def body_css_classes
            classes = body_css_classes_without_expert_ui.to_s.split(' ').reject { |name| name.start_with?('theme-') }
            theme = current_theme
            classes.unshift('theme-' + theme.name.tr(' ', '_')) if theme
            classes.join(' ')
          end
        end
      end
    end
  end
end
