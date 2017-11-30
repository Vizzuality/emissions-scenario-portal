class Team < ApplicationRecord
  has_many :users, dependent: :restrict_with_error
  has_many :models, dependent: :nullify

  validates :name, presence: true, uniqueness: true

  has_attached_file :image, storage: :s3,
    path: "#{Rails.env}/:class/:id/:filename",
    styles: {
      thumb: '300x300>'
    }

  validates_attachment_content_type :image,
                                    content_type: ['image/jpeg', 'image/png']
  validates_attachment_size :image, in: 0.kilobytes..500.kilobytes

  accepts_nested_attributes_for :users

  def self.models
    joins('LEFT JOIN "models" ON "models"."team_id" = "teams"."id"').
      group('teams.id')
  end

  def self.users
    joins('LEFT JOIN "users" ON "users"."team_id" = "teams"."id"').
      group('teams.id')
  end

  def members_list_for_display
    users.select([:name, :email]).map do |user|
      user.name.presence || user.email
    end.sort.join(', ')
  end
end
