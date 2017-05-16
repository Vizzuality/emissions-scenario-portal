class UploadTimeSeriesValues
  def initialize(user, model)
    @user = user
    @model = model
    @errors = {}
  end

  def call(uploaded_io)
    store_file(uploaded_io) # TODO: record the fact of the upload?
    begin
      data = TimeSeriesValuesData.new(@path)
      data.process
    ensure
      discard_file
    end
    FileUploadStatus.new(
      data.number_of_rows,
      data.number_of_rows_failed,
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
