module UserStoryHelper
  def set_user_stories(hypothesis)
    stories = []
    3.times { stories.push(create :user_story, hypothesis: hypothesis) }
    stories
  end

  def set_user_stories_on_project(project)
    stories = []
    3.times { stories.push(create :user_story, project: project) }
    stories
  end

  def get_reordered(first_story, second_story, third_story)
    UserStory.find(first_story.id, second_story.id, third_story.id)
  end
end
