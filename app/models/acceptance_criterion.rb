class AcceptanceCriterion < ActiveRecord::Base
  validates_presence_of :description
  validates_uniqueness_of :description, scope: :user_story_id
  before_create :assign_order
  belongs_to :user_story

  def log_description
    description
  end

  def assign_story(user_story)
    self.user_story = user_story
    save
  end

  def as_json(*_args)
    { id: id, description: description }
  end

  def self.from_hash(hash, story)
    story
      .acceptance_criterions
      .where(description: hash['description'])
      .first_or_create
  end

  private

  def assign_order
    self.order = user_story.acceptance_criterions.maximum(:order).to_i + 1
  end
end
