class Admin::MembersController < Admin::ApplicationController
  before_action :set_member, only: %i[events update_subscriptions send_attendance_email send_eligibility_email]

  def index
    # @members = Member.all removed - members loaded dynamically via search
  end

  def search
    query = params[:q].to_s.strip

    members = if query.length >= 3
      Member.where(
        "CONCAT(name, ' ', surname) ILIKE :q OR email ILIKE :q",
        q: "%#{query}%"
      ).select(:id, :name, :surname, :email, :pronouns).limit(50)
    else
      []
    end

    render json: members.as_json(
      only: %i[id name surname email],
      methods: [:full_name]
    )
  end

  def show
    @member = MemberPresenter.new(Member.find(params[:id]))
    load_attendance_data(@member)

    @actions = admin_actions(@member).sort_by(&:created_at).reverse
  end

  def events
    load_attendance_data(@member)

    @member = MemberPresenter.new(@member)
    @pagy, @past_rsvps = pagy(:offset, @member.past_rsvps)
  end

  def update_subscriptions
    subscription = @member.subscriptions.find_by(group_id: params[:group])
    flash[:notice] = t('.unsubscribe', member: @member.full_name,
                                       chapter: subscription.group.chapter.city,
                                       group: subscription.group.name)
    subscription.destroy
    redirect_back fallback_location: root_path
  end

  def send_eligibility_email
    @member.eligibility_inquiries.create!(issued_by: current_user)

    redirect_to [:admin, @member], notice: t('.success')
  end

  def send_attendance_email
    @member.attendance_warnings.create!(issued_by: current_user)

    redirect_to [:admin, @member], notice: t('.success')
  end

  private

  def set_member
    @member = Member.find(params[:member_id])
  end

  def load_attendance_data(member)
    @workshop_attendances = member.workshop_invitations.joins(:workshop).taken_place.attended.count
    @event_rsvps = member.invitations.joins(:event).taken_place.accepted.count
    @meeting_rsvps = member.meeting_invitations.joins(:meeting).taken_place.count
  end

  def admin_actions(member)
    [member.bans,
     member.member_notes,
     member.eligibility_inquiries,
     member.attendance_warnings].reduce([], :concat)
  end
end
