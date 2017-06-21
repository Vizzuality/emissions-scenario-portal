FileUploadError = Struct.new(:message, :suggestion, :link, :link_placeholder) do
  def suggestion_with_link
    suggestion.sub(link_placeholder, link)
  end

  def to_s
    [message, suggestion_with_link].join(' ')
  end
end
