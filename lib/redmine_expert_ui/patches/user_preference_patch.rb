module RedmineExpertUi
  module Patches
    # pref[refresh_interval] from My account and the admin's user form. Core
    # saves both through UserPreference#safe_attributes=, and keys that are no
    # column live in the serialized `others` hash, where redmine_refresh kept
    # the same value - so a user's interval carries over.
    module UserPreferencePatch
      def self.apply!
        return if UserPreference.included_modules.include?(InstanceMethods)

        UserPreference.send(:include, InstanceMethods)
        UserPreference.safe_attributes 'refresh_interval', 'expert_ui_theme', 'expert_ui_cancel_guard_style'
      end

      module InstanceMethods
        def refresh_interval
          value = self[:refresh_interval].to_i
          value >= RedmineExpertUi::MIN_INTERVAL ? value : nil
        end

        # Blank removes the personal interval, so the default applies. Anything
        # else is stored as whole seconds, at least MIN_INTERVAL: My account
        # saves the preferences without checking them, so a validation error
        # would be swallowed rather than shown.
        def refresh_interval=(value)
          value = value.to_s.strip
          self[:refresh_interval] = value.empty? ? nil : [value.to_i, RedmineExpertUi::MIN_INTERVAL].max
        end

        # pref[expert_ui_theme]: the id (directory name) of the user's theme,
        # nil for the global one.
        def expert_ui_theme
          value = self[:expert_ui_theme].to_s
          value.empty? ? nil : value
        end

        # Anything that is not an installed theme clears the choice.
        def expert_ui_theme=(value)
          value = value.to_s.strip
          self[:expert_ui_theme] = Redmine::Themes.themes.any? { |theme| theme.id == value } ? value : nil
        end

        # pref[expert_ui_cancel_guard_style]: the user's own cancel guard style,
        # nil for the one set in the plugin settings.
        def expert_ui_cancel_guard_style
          value = self[:expert_ui_cancel_guard_style].to_s
          value.empty? ? nil : value
        end

        # Anything that is not a known style clears the choice.
        def expert_ui_cancel_guard_style=(value)
          value = value.to_s.strip
          self[:expert_ui_cancel_guard_style] = RedmineExpertUi.cancel_guard_style?(value) ? value : nil
        end
      end
    end
  end
end
