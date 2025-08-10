class Admin::MemberSearchController < Admin::ApplicationController
  def index
    @params = params[:member_search] || {}
    @name = @params[:name]
    @members = @name.blank? ? Member.none : Member.find_members(@name).select(:id, :name, :surname, :pronouns)
    @callback_url = @params[:callback] || results_admin_member_search_index_path
    if (@members.size == 1) && @callback_url.present?
      query = { member_pick: { members: [@members.pluck(:id)] } }
      query_string = query.to_query
      @callback_url = "#{@callback_url}?#{query_string}"
      redirect_to @callback_url and return
    end

    render 'index', locals: { members: @members, callback: @callback_url }
  end

  def results
    @members = Member.find(params[:member_pick][:members])
    render 'show', locals: { members: @members }
  end
end
