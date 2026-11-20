class ChapterContactMailer < ApplicationMailer
  include EmailHeaderHelper

  DEFAULT_MESSAGE = <<~HTML.freeze
    <p>Hello,</p>

    <p>Write your message here.</p>

    <p>Best,<br>Your name</p>
  HTML
  MESSAGE_TAGS = %w[a b blockquote br div em h1 h2 h3 hr i li ol p span strong u ul].freeze
  MESSAGE_ATTRIBUTES = %w[href title].freeze

  def contact
    @chapter = params.fetch(:chapter)
    @message = params.fetch(:message)

    mail_to_member(params.fetch(:recipient), params.fetch(:subject), @chapter.email, &:html)
  end
end
