FileUploadError = Struct.new(
  :message, :suggestion, :link_options
) do
  def suggestion_with_link
    if link_options
      url = link_options[:url]
      placeholder = link_options[:placeholder]
      suggestion.sub(
        /\[#{placeholder}\]/, "<a href=\"#{url}\">#{placeholder}</a>"
      )
    else
      suggestion
    end
  end
end
