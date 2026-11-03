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
        UserPreference.safe_attributes 'refresh_interval'
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
      end
    end
  end
end
