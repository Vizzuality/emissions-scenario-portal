FactoryGirl.define do
  factory :csv_upload do
    job_id 1
    user nil
    model nil
    service_type 'UploadIndicators'
    finished_at '2017-07-28 16:24:19'
    success false
    message 'MyText'
    errors_and_warnings {}
  end
end
