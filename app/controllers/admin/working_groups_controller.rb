class Admin::WorkingGroupsController < Admin::ApplicationController
  before_action :set_workshop_and_authorize
  before_action :ensure_working_groups_enabled

  def index
    board = service.board
    etag = formatted_etag(board)
    response.headers['ETag'] = etag
    return head :not_modified if request.headers['If-None-Match'] == etag

    render json: board_payload(board, etag)
  end

  def create
    board = service.assign(
      entry_id: params.expect(:invitation_id),
      target_group_id: params[:target_group_id].presence,
      target_entry_id: params[:target_invitation_id].presence
    )
    respond_with_board(board)
  end

  def destroy
    board = service.unassign(entry_id: params.expect(:invitation_id))
    respond_with_board(board)
  end

  private

  def set_workshop_and_authorize
    @workshop = Workshop.find(params[:workshop_id])
    authorize @workshop, :update?
  end

  def ensure_working_groups_enabled
    head :unprocessable_content unless service.enabled?
  end

  def service
    @service ||= WorkingGroups::Service.for(@workshop)
  end

  def respond_with_board(board)
    etag = formatted_etag(board)
    response.headers['ETag'] = etag

    respond_to do |format|
      format.json { render json: board_payload(board, etag) }
      format.html { redirect_to admin_workshop_path(@workshop) }
    end
  end

  def formatted_etag(board)
    %("#{board.etag}")
  end

  def board_payload(board, etag)
    {
      board_html: render_to_string(
        partial: 'admin/workshops/working_groups',
        formats: [:html],
        locals: { workshop: @workshop, board: }
      ),
      etag:,
      counts: board.counts.to_h
    }
  end
end
