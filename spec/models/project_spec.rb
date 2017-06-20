require 'spec_helper'

describe Project do
  let(:project) { create :project, is_template: false }
  let(:user)    { create :user }
  let(:team)    { create :team, users: [user] }

  subject       { project }

  it { should validate_presence_of :name }
  it { should validate_uniqueness_of(:name).scoped_to(:owner_id).with_message('Project name already exists') }
  it { should validate_uniqueness_of(:slack_channel_id).allow_nil }
  it { should validate_uniqueness_of(:slack_iw_url).allow_nil }
  it { should have_many :invites }
  it { should have_many :members }
  it { should have_many :user_stories }
  it { should have_many :attachments }
  it { should have_many :sprints }
  it { should belong_to :owner }
  it { should belong_to :team }
  it { should_not validate_uniqueness_of(:is_template) }
  it { should validate_numericality_of(:velocity).is_greater_than_or_equal_to(0).allow_nil }

  feature '#exclude_project' do
    before do
      create_list(:project, 3)
    end

    scenario 'removes a project from the scope' do
      project = create(:project)

      expect(Project.exclude_project(project)).to_not include(project)
    end
  end

  context 'if is_tremplate is true' do
    before :each do
      project.update_attributes(is_template: true)
    end

    it { should validate_uniqueness_of(:is_template) }
  end

  describe 'add member' do
    it 'adds a member and creates an activity' do
      PublicActivity.with_tracking do
        project.add_member(user)
        expect(project.members).to include(user)
        expect(PublicActivity::Activity.last.key).to eq('project.add_member')
      end
    end
  end

  describe 'assign_team' do
    it 'assigns team and owner without logging activity' do
      PublicActivity.with_tracking do
        project.assign_team(team.name, user)
        expect(project.members).to include(team.owner)
        expect(project.team).to eq(team)
        expect(project.owner).to eq(team.owner)
        expect(PublicActivity::Activity.last).to eq(nil)
      end
    end
  end

  describe 'owner_as_member' do
    it 'should assign owner as member' do
      expect(project.members).to include(project.owner)
    end
  end

  describe '#points_per_week' do
    let(:project) { create :project }
    before(:each) { allow(project).to receive(:total_points).and_return(10) }

    context 'when having velocity' do
      before(:each) { project.update velocity: 1 }

      it { expect(project.points_per_week).to eq 1 }
    end

    context 'when having velocity' do
      before(:each) { project.update velocity: 0 }

      it { expect(project.points_per_week).to eq 0 }
    end

    context 'when not having velocity' do
      it { expect(project.points_per_week).to eq 10 }
    end
  end
end
