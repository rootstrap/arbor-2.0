include Gravtastic
class User < ActiveRecord::Base
  INTERCOM_ENABLED = ENV['ENABLE_INTERCOM'] == 'true'

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  gravtastic default: 'blank', size: 150

  validates_presence_of :full_name
  validates_presence_of :email
  validates_uniqueness_of :email
  validates_uniqueness_of :slack_id, allow_nil: true
  validates_uniqueness_of :slack_auth_token, allow_nil: true

  has_many :members_projects,
           foreign_key: :member_id,
           class_name: MembersProject
  has_many :projects, through: :members_projects
  has_many :owned_projects, foreign_key: :owner_id, class_name: Project
  has_many :owned_teams, foreign_key: :owner_id, class_name: Team
  has_many :comments
  has_many :team_users
  has_many :teams, through: :team_users
  has_many :user_stories, through: :projects
  has_many :acceptance_criterions, through: :user_stories
  has_one :api_key, dependent: :destroy
  after_commit :generate_api_key, on: %i(create update)
  after_update :update_intercom, if: :email_changed?
  after_create :track_sign_up

  mount_uploader :avatar, UserAvatarImageUploader
  delegate :access_token, to: :api_key, prefix: false

  scope :user_first,
          -> (id) { order("CASE WHEN users.id = #{id.to_i} THEN 0 ELSE 1 END") }

  def can_delete?(project)
    self == project.owner
  end

  def available_projects
    projects + Project.by_teams(teams).all
  end

  def log_description
    full_name
  end

  def self.from_hash(hash)
    filters = { email: hash['email'], full_name: hash['full_name'] }

    User.find_or_initialize_by(filters) do |user|
      user.password = 'ChangeMePlease'
      user.save
    end
  end

  private

  def generate_api_key
    return if api_key
    create_api_key!
  end

  def update_intercom
    return unless INTERCOM_ENABLED
    ArborReloaded::IntercomServices.new(self).user_create_event
  end

  def track_sign_up
    tracker_services = Mixpanel::TrackerServices.new
    tracker_services.track_event(id, 'USER_SIGNS_UP')
  end
end
