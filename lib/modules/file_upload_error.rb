FileUploadError = Struct.new(
  :message, :suggestion, :link_options
) do
  def suggestion_with_link
    suggestion.sub(
      /\[#{link_options[:placeholder]}\]/,
      "<a href=\"#{link_options[:url]}\">#{link_options[:placeholder]}</a>"
    )
  end

  def to_s
    [message, suggestion_with_link].join(' ')
  end
end
