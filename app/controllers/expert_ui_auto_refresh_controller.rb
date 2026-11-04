# Saves whether the automatic refresh is on, per user and page. A POST from the
# link (CSRF token in the header) replaces redmine_refresh's ?refresh= /
# ?norefresh= parameters, which changed the preference on a GET.
class ExpertUiAutoRefreshController < ApplicationController
  before_action :require_login
  before_action :check_feature

  def update
    page = params[:page].to_s
    return render_404 unless RedmineExpertUi::REFRESH_PAGES.key?(page)

    on = params[:enabled].to_s == '1'
    RedmineExpertUi.save_refresh_state(User.current, page, on)
    render :json => { :page => page, :enabled => on, :interval => RedmineExpertUi.interval_for(User.current) }
  end

  private

  def check_feature
    render_404 unless RedmineExpertUi.active?('auto_refresh')
  end
end
