class Admin::MemberSearchController < Admin::ApplicationController
  def index
    member_params = params[:member_search] || {}
    name = member_params[:name]
    @members = name.blank? ? Member.none : Member.find_members(name).select(:id, :name, :surname, :pronouns)
    @callback_url = member_params[:callback_url] || params[:callback_url] || results_admin_member_search_index_path
    if @members.size == 1
      query = { member_pick: { members: [@members.first.id] } }
      query_string = query.to_query
      callback_url = "#{@callback_url}?#{query_string}"
      redirect_to callback_url and return
    end

    render 'index', locals: { members: @members, callback_url: @callback_url }
  end

  def results
    @members = Member.find(params[:member_pick][:members])
    render 'show', members: @members
  end
end
