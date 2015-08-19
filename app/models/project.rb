class Project < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  belongs_to :owner, class_name: User
  has_many :members_projects, class_name: MembersProject
  has_many :members, class_name: User, through: :members_projects
  has_many :hypotheses, dependent: :destroy
  has_many :invites, dependent: :destroy
  has_one :canvas, dependent: :destroy
  has_many :user_stories, dependent: :destroy

  def as_json
    super(only: [:name])
  end
end
