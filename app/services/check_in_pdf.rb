# frozen_string_literal: true

class CheckInPdf
  def initialize(parent)
    @parent = parent
  end

  def render
    Prawn::Document.new(page_layout: :landscape, page_size: "A4", margin: 20) do |pdf|
      logo_path = Rails.root.join("app/assets/images/check_in/logo.png")
      if File.exist?(logo_path)
        pdf.image logo_path, width: 250, position: :center
      else
        pdf.text "codebar", size: 24, style: :bold, align: :center
      end
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

  def formatted_date
    dt = @parent.date_and_time
    dt.strftime("%A, %B %d, %Y at %H:%M")
  end
end
