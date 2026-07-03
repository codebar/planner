# frozen_string_literal: true

class CheckInPdf
  def initialize(parent)
    @parent = parent
  end

  def render
    Prawn::Document.new(page_layout: :landscape, page_size: "A4", margin: [40, 20, 20, 20]) do |pdf|
      draw_logo(pdf)
      pdf.move_down 12

      pdf.text @parent.to_s, size: 28, style: :bold
      pdf.move_down 4
      pdf.text formatted_date, size: 16, color: "555555"
      pdf.move_down 8

      if @parent.respond_to?(:venue) && @parent.venue.present?
        venue = @parent.venue
        pdf.text venue.name, size: 14, color: "555555"
        if venue.respond_to?(:address) && venue.address.present?
          pdf.text AddressPresenter.new(venue.address).to_s, size: 12, color: "777777"
        end
        pdf.move_down 4
      end

      if @parent.respond_to?(:sponsors) && @parent.sponsors.any?
        pdf.text "Sponsored by: #{@parent.sponsors.map(&:name).join(', ')}", size: 12, color: "777777"
        pdf.move_down 8
      end

      qrcode = RQRCode::QRCode.new(@parent.check_in_url)
      png = qrcode.as_png(module_size: 6)
      qr_width = 160

      pdf.image StringIO.new(png.to_blob),
                width: qr_width,
                position: :center
      pdf.move_down 4
      pdf.text "Scan to check in", size: 11, align: :center, color: "999999"
      pdf.move_down 2
      pdf.text @parent.check_in_url,
               size: 10, align: :center, color: "999999"
    end.render
  end

  private

  def draw_logo(pdf)
    svg_path = Rails.root.join("app/assets/images/check_in/logo.svg")

    if File.exist?(svg_path)
      svg_content = File.read(svg_path)
      mark_size = 60
      label_size = 28

      pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width, height: mark_size + 4) do
        pdf.svg svg_content, width: mark_size, at: [0, mark_size], enable_web_requests: false
        pdf.draw_text "codebar", at: [mark_size + 10, mark_size - 16], size: label_size
      end
    else
      pdf.text "codebar", size: 24, style: :bold, align: :center
    end
  end

  def formatted_date
    dt = @parent.date_and_time
    dt.strftime("%A, %B %d, %Y at %H:%M")
  end
end
