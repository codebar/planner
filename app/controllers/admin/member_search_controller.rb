class Admin::MemberSearchController < Admin::ApplicationController
  def index
    search_params = if params.key?(:member_search)
                      params.expect(member_search: [:name, :callback_url])
                    else
                      {}
                    end

    callback_url = search_params[:callback_url] || params[:callback_url] || results_admin_member_search_index_path
    name = search_params[:name]
    members = name.blank? ? Member.none : Member.find_members_by_name(name).select(:id, :name, :surname, :pronouns)

    if members.size == 1
      query = { member_pick: { members: [members.first.id] } }
      query_string = query.to_query
      callback_url = "#{callback_url}?#{query_string}"
      redirect_to callback_url and return
    end

    render 'index', locals: { members: members, callback_url: callback_url }
  end

  def results
    pick_params = params.expect(member_pick: { members: [] })
    members = Member.find(pick_params[:members])
    render 'show', locals: { members: members }
  end
end
