class ChapterContactMailer < ApplicationMailer
  include EmailHeaderHelper

  def contact
    @chapter = params.fetch(:chapter)
    @message = params.fetch(:message)

    mail_to_member(params.fetch(:recipient), params.fetch(:subject), @chapter.email, &:html)
  end
end
