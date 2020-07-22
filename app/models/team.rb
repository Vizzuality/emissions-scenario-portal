class Team < ApplicationRecord
  has_many :users, dependent: :restrict_with_error
  has_many :models, dependent: :nullify

  validates :name, presence: true, uniqueness: true

  has_attached_file :image, storage: :s3,
    path: "emissionspathways.org/#{Rails.env.production? ? 'www': 'staging'}.emissionspathways.org/#{Rails.env}/:class/:id/:filename",
    styles: {
      thumb: '300x300>'
    }

  validates_attachment_content_type :image,
                                    content_type: ['image/jpeg', 'image/png']
  validates_attachment_size :image, in: 0.kilobytes..2.megabytes

  accepts_nested_attributes_for :users

  def self.models
    left_outer_joins(:models).group('teams.id')
  end

  def self.users
    left_outer_joins(:users).group('teams.id')
  end

  def members_list_for_display
    users.select([:name, :email]).map do |user|
      user.name.presence || user.email
    end.sort.join(', ')
  end
end
