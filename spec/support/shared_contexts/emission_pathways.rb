RSpec.shared_context 'emission pathways' do
  let(:spain) {
    FactoryBot.create(
      :location, iso_code: 'ES', name: 'Spain'
    )
  }
  let(:model) {
    FactoryBot.create(:model)
  }
  let(:scenario) {
    FactoryBot.create(:scenario, model: model)
  }
  let(:category_1) { FactoryBot.create(:category, name: 'Canis') }
  let(:subcategory_1) {
    FactoryBot.create(:category, name: 'lupus', parent: category_1)
  }
  let(:indicator_1) {
    FactoryBot.create(:indicator, subcategory: subcategory_1, name: 'dingo')
  }
  let(:category_2) { FactoryBot.create(:category, name: 'Panthera') }
  let(:subcategory_2) {
    FactoryBot.create(:category, name: 'leo', parent: category_2)
  }
  let(:indicator_2) {
    FactoryBot.create(:indicator, subcategory: subcategory_2, name: 'persica')
  }
  let(:indicator_1970) {
    FactoryBot.create(:indicator, subcategory: subcategory_2, name: 'manatu')
  }
  let(:indicator_1970_value) {
    FactoryBot.create(
      :time_series_value,
      scenario: scenario,
      indicator: indicator_1970,
      location: spain,
      year: 1970,
      value: 1.0
    )
  }
  let(:indicator_with_null) {
    FactoryBot.
      create(:indicator, subcategory: subcategory_2, name: 'with nulls')
  }
  let!(:indicator_1_value) {
    FactoryBot.create(
      :time_series_value,
      scenario: scenario,
      indicator: indicator_1,
      location: spain,
      year: 2030,
      value: 1.0
    )
  }
  let!(:indicator_2_value) {
    FactoryBot.create(
      :time_series_value,
      scenario: scenario,
      indicator: indicator_2,
      location: spain,
      year: 2030,
      value: 2.0
    )
  }
  let!(:indicator_with_null_value) {
    FactoryBot.create(
      :time_series_value,
      scenario: scenario,
      indicator: indicator_with_null,
      location: spain,
      year: 2020,
      value: 3.0
    )
  }
end
