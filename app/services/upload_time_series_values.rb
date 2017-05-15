class UploadTimeSeriesValues
  def initialize(user, model)
    @user = user
    @model = model
    @errors = {}
  end

  def call(uploaded_io)
    store_file(uploaded_io) # TODO: record the fact of the upload?
    headers = TimeSeriesValuesHeaders.new(@path)
    if headers.errors.any?
      discard_file
      return FileUploadStatus.new(0, 0, headers.errors)
    end
    data = TimeSeriesValuesData.new(@path, headers)
    data.process
    discard_file
    FileUploadStatus.new(
      data.number_of_rows_read,
      data.number_of_rows_saved,
      data.errors
    )
  end

  def store_file(uploaded_io)
    @filename = "#{Time.now.getutc}-#{uploaded_io.original_filename}"
    @path = Rails.root.join('public', 'uploads', @filename)
    File.open(@path, 'wb') do |file|
      file.write(uploaded_io.read)
    end
  end

  def discard_file
    FileUtils.rm(@path)
  end
end
