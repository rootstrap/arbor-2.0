require 'spec_helper'

feature 'Log lab activity' do
  let!(:user) { create :user }

  background do
    sign_in user
  end

  context 'for creating projects' do
    scenario 'should log project creation' do
      PublicActivity.with_tracking do
        within '.content-general' do
          click_link 'Create new project'
        end
        fill_in 'project_name', with: 'Test Project'
        click_button 'Save Project'
      end

      project_activities = Project.first.activities
      expect(project_activities.count).to eq 2
      expect(project_activities.first.key).to eq 'project.create'
    end

    scenario 'should log adding the owner as a member' do
      PublicActivity.with_tracking do
        within '.content-general' do
          click_link 'Create new project'
        end
        fill_in 'project_name', with: 'Test Project'
        click_button 'Save Project'
      end

      expect(Project.first.activities.second.key).to eq 'project.add_member'
    end

    scenario 'should not create logs when the save fails' do
      PublicActivity.with_tracking do
        within '.content-general' do
          click_link 'Create new project'
        end
        click_button 'Save Project'
      end

      expect(PublicActivity::Activity.all).to be_empty
    end
  end

  context 'for an existing project' do
    let!(:project)         { create :project, owner: user }

    context 'hypotheses' do
      let!(:hypothesis_type) { create :hypothesis_type }
      let(:hypothesis)       { build :hypothesis }

      background do
        visit project_path project
      end

      scenario 'should log adding hypotheses' do
        click_link project.name

        PublicActivity.with_tracking do
          within '.hypothesis-new' do
            fill_in 'hypothesis_description', with: hypothesis.description
            find(
              '#hypothesis_hypothesis_type_id'
            ).select(hypothesis_type.description)
            click_button 'Save'
          end
        end

        last_actvity = PublicActivity::Activity.last
        expect(last_actvity.key).to eq 'project.add_hypothesis'
      end

      scenario 'should log removing hypotheses' do
        create :hypothesis, project: project
        click_link project.name

        PublicActivity.with_tracking do
          find('.delete-hypothesis').click
        end

        last_actvity = PublicActivity::Activity.last
        expect(last_actvity.key).to eq 'project.remove_hypothesis'
      end
    end

    context 'invites' do
      let(:invitee) { build :user }

      background do
        visit edit_project_path project
      end

      scenario 'should log inviting members', js: true do
        click_button 'New Member'
        fill_in 'member_0', with: invitee.email

        PublicActivity.with_tracking do
          click_button 'Update Project'
        end

        last_actvity = PublicActivity::Activity.last
        expect(last_actvity.key).to eq 'project.add_invite'
      end
    end

    context 'epics' do
      let!(:hypothesis) { create :hypothesis, project: project }
      let(:epic)        { build :epic }

      background do
        visit project_path project
      end

      scenario 'should log adding epics' do
        click_link project.name

        within 'form.new_user_story' do
          fill_in :user_story_role, with: epic.role
          fill_in :user_story_action, with: epic.action
          fill_in :user_story_result, with: epic.result

          PublicActivity.with_tracking do
            click_button 'Save'
          end
        end

        activities = PublicActivity::Activity.all
        expect(activities.first.key).to eq 'user_story.create'
        expect(activities.second.key).to eq 'project.add_user_story'
        expect(activities.third.key).to eq 'hypothesis.add_user_story'
      end

      scenario 'should log removing epics' do
        create :epic, project: hypothesis.project, hypothesis: hypothesis
        click_link project.name

        PublicActivity.with_tracking do
          within '.user-story' do
            find('.delete-user-story').click
          end
        end

        activities = PublicActivity::Activity.all
        expect(activities.first.key).to eq 'user_story.destroy'
        expect(activities.second.key).to eq 'project.remove_user_story'
      end
    end

    context 'goals' do
      let!(:hypothesis) { create :hypothesis, project: project }
      let(:goal)        { build :goal }

      background do
        visit project_path project
      end

      scenario 'should log adding goals' do
        click_link project.name

        within '.new-goal' do
          fill_in :goal_title, with: goal.title
          PublicActivity.with_tracking do
            click_button 'Save'
          end
        end

        activities = PublicActivity::Activity.all
        expect(activities.first.key).to eq 'goal.create'
        expect(activities.second.key).to eq 'hypothesis.add_goal'
      end

      scenario 'should log removing goals' do
        create :goal, hypothesis: hypothesis

        click_link project.name

        within '.goals' do
          PublicActivity.with_tracking do
            click_link 'Delete Goal'
          end
        end

        activities = PublicActivity::Activity.all
        expect(activities.first.key).to eq 'goal.destroy'
        expect(activities.second.key).to eq 'hypothesis.remove_goal'
      end
    end
  end
end
