module PdfHelper
  def pdf_output_field(pdf, title, value)
    pdf.start_new_page if pdf.cursor < 25
    pdf.text title, style: :bold
    pdf.indent(20) do
      pdf.text value.present? ? value.encode("Windows-1252", invalid: :replace, undef: :replace, replace: " ") : ""
    end
    pdf.move_down 20
  end

  def pdf_header(pdf, text)
    if pdf.cursor < 60
      pdf.start_new_page
    else
      pdf.move_down 15
    end
    pdf.text text, style: :bold, size: 16
  end
end
