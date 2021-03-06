require 'spec_helper'

RSpec.describe UserStory do
  let(:project)     { create :project }
  let(:user_story)  { create :user_story }
  subject           { user_story }

  it { should have_many :acceptance_criterions }
  it { should belong_to(:project) }
  it { should have_many :acceptance_criterions }
  it { should validate_uniqueness_of(:story_number).scoped_to(:project_id)}
  it { should validate_numericality_of(:color).only_integer }
  it { should validate_numericality_of(:color).allow_nil }
  it { should validate_numericality_of(:color).is_greater_than_or_equal_to(1) }
  it { should validate_numericality_of(:color).is_less_than_or_equal_to(7) }
  it { should have_many :sprint_user_stories }
  it { should have_many :sprints }

  it 'must increment user story number' do
    test_project = create :project
    user_stories = create_list :user_story, 3, project: test_project
    user_stories.each_with_index do |user_story, index|
      expect(user_story.story_number).to eq(index + 1)
    end
  end

  it 'must increase user stories backlog order' do
    create_list(:user_story, 3, project: project)

    expect(project.user_stories.pluck(:backlog_order).sort).to eq([1, 2, 3])
  end

  context 'new story' do
    it 'is added at the end of backlog' do
      create_list(:user_story, 3, project: project)
      new_story = create(:user_story, project: project)

      expect(project.user_stories.backlog_ordered.last.id).to be(new_story.id)
    end
  end

  it_behaves_like 'a logged entity' do
    let(:entity) do
      build :user_story, role: 'User', action: 'to work', result: 'test'
    end
    let(:description) { 'As a User I want to work so that test' }
  end

  describe 'story_number' do
    it 'should assign unique story numbers' do
      user_stories = create_list :user_story, 2, project: project

      expect(user_stories.first.story_number).to eq 1
      expect(user_stories.second.story_number).to eq 2

      user_stories.second.destroy

      next_story = create :user_story, project: project
      expect(next_story.story_number).to eq 3
    end
  end

  describe 'fibonacci series' do
    it 'should only list the first 7 fibonacci numbers for estimation' do
      numbers = UserStory.estimation_series
      expect(numbers.count).to eq 8
      expect(numbers).to eq [nil, 1, 2, 3, 5, 8, 13, 21]
    end
  end

  describe 'log description' do
    let(:story) { create :user_story }
    it 'should use the new description with I want' do
      expect(story.log_description).to eq("As a #{story.role} I want #{story.action} so that #{story.result}")
    end
  end

  describe 'if attributes are missing' do
    let(:story)                { build :user_story }
    let(:no_role)              { build :user_story, :no_role }
    let(:no_action)            { build :user_story, :no_action }
    let(:no_result)            { build :user_story, :no_result }
    let(:no_role_and_action)   { build :user_story, :no_role_and_action }
    let(:no_role_and_result)   { build :user_story, :no_role_and_result }
    let(:no_action_and_result) { build :user_story, :no_action_and_result }

    describe 'when description is nil' do
      it 'should save if role, action and result are present' do
        expect(story.save).to eq(true)
      end

      it 'should not save without role' do
        expect(no_role.save).to eq(false)
      end

      it 'should not save without action' do
        expect(no_action.save).to eq(false)
      end

      it 'should not save without result' do
        expect(no_result.save).to eq(false)
      end

      it 'should not save without role and action' do
        expect(no_role_and_action.save).to eq(false)
      end

      it 'should not save without role and result' do
        expect(no_role_and_result.save).to eq(false)
      end

      it 'should not save without action and result' do
        expect(no_action_and_result.save).to eq(false)
      end
    end

    describe 'when description is present' do
      it 'should save without role' do
        no_role.update_attribute(:description, 'This is the story')
        expect(no_role.save).to eq(true)
      end

      it 'should save without action' do
        no_action.update_attribute(:description, 'This is the story')
        expect(no_action.save).to eq(true)
      end

      it 'should save without result' do
        no_result.update_attribute(:description, 'This is the story')
        expect(no_result.save).to eq(true)
      end

      it 'should save without result and role' do
        no_role_and_result.update_attribute(:description, 'This is the story')
        expect(no_role_and_result.save).to eq(true)
      end

      it 'should save without result and action' do
        no_action_and_result.update_attribute(:description, 'This is the story')
        expect(no_action_and_result.save).to eq(true)
      end

      it 'should save without role and action' do
        no_role_and_action.update_attribute(:description, 'This is the story')
        expect(no_role_and_action.save).to eq(true)
      end
    end
  end

  describe 'copy' do
    let(:user_story) { create :user_story }
    let(:project)    { create :project }

    before(:each) do
      user_story.copy_out_project(project)
      @new_user_story = find_user_story(project, user_story)
    end

    def find_user_story(project, user_story)
      project.user_stories.find_by(
        role: user_story.role,
        action: user_story.action,
        result: user_story.result,
        estimated_points: user_story.estimated_points,
        priority: user_story.priority
      )
    end

    describe '#copy_in_project' do
      context 'when duplicating a story' do
        it { expect(@new_user_story.color).to eq(user_story.color) }
      end

      context 'when the target project does not have user stories' do
        it { expect(@new_user_story.story_number).to eq(user_story.story_number) }
      end

      context 'when the target project has many user stories' do
        prepend_before(:each) do
          user_stories = create_list :user_story, 10
          project.user_stories << user_stories
        end

        it { expect(@new_user_story.story_number).to eq(user_story.story_number) }
      end
    end

    describe '#copy_out_project' do
      context 'when duplicating a story' do
        it { expect(@new_user_story.color).to eq(user_story.color) }
      end

      context 'when the target project does not have user stories' do
        it { expect(@new_user_story.story_number).to eq 1 }
      end

      context 'when the target project has many user stories' do
        prepend_before(:each) do
          user_stories = create_list :user_story, 10
          project.user_stories << user_stories
        end

        it { expect(@new_user_story.story_number).to eq(project.next_story_number - 1) }
      end
    end
  end

  describe '#done?' do
    let(:sprint)                 { create :sprint, project: user_story.project }
    let(:sprint_user_story)      { create :sprint_user_story, user_story: subject, sprint: sprint }
    let(:done_sprint_user_story) { create :sprint_user_story, :done, user_story: subject, sprint: sprint }

    it 'should return false if sprint user story status is not done' do
      sprint_user_story
      expect(user_story.done?).to be_falsey
    end

    it 'should return true if sprint user story status is not done' do
      done_sprint_user_story
      expect(user_story.done?).to be_truthy
    end
  end
end
