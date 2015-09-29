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
        find('.create-project-btn').click
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
        find('.create-project-btn').click
      end

      expect(Project.first.activities.second.key).to eq 'project.add_member'
    end

    scenario 'should not create logs when the save fails' do
      PublicActivity.with_tracking do
        within '.content-general' do
          click_link 'Create new project'
        end
        find('.create-project-btn').click
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
        visit project_hypotheses_path project
      end

      scenario 'should log adding hypotheses' do
        PublicActivity.with_tracking do
          within '.hypothesis-new' do
            fill_in 'hypothesis_description', with: hypothesis.description
            find('#hypothesis_hypothesis_type_id').select(hypothesis_type.description)
            click_button 'Save'
          end
        end

        last_actvity = PublicActivity::Activity.last
        expect(last_actvity.key).to eq 'project.add_hypothesis'
      end

      scenario 'should log removing hypotheses' do
        create :hypothesis, project: project
        visit current_path

        PublicActivity.with_tracking do
          within '.hypothesis-show' do
            find('.delete-hypothesis').click
          end
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

    context 'user stories' do
      let!(:hypothesis) { create :hypothesis, project: project }
      let(:user_story)  { build :user_story }

      background do
        visit project_hypotheses_path project
      end

      scenario 'should log adding user stories' do
        visit current_path

        within 'form.new_user_story' do
          fill_in :user_story_role, with: user_story.role
          fill_in :user_story_action, with: user_story.action
          fill_in :user_story_result, with: user_story.result

          PublicActivity.with_tracking do
            click_button 'Save'
          end
        end

        activity_keys = PublicActivity::Activity.pluck(:key)
        expect(activity_keys).to include 'user_story.create'
        expect(activity_keys).to include 'project.add_user_story'
        expect(activity_keys).to include 'hypothesis.add_user_story'
      end

      scenario 'should log removing user stories' do
        create :user_story, project: hypothesis.project, hypothesis: hypothesis
        visit current_path

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
        visit project_hypotheses_path project
      end

      scenario 'should log adding goals' do
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

        visit current_path

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

  context 'displaying the log' do
    background do
      PublicActivity.with_tracking do
        @project = create :project, owner: user
      end
      visit project_path(@project)
    end

    scenario 'should show the Activity link on the sidebar to access the log' do
      within '#sidebar' do
        expect(page).to have_link 'Activity'
      end
    end

    scenario 'should display the log after following the link' do
      within '#sidebar' do
        click_link 'Activity'
      end

      expect(page).to have_content 'The project was created'
      expect(page).to have_content 'A new collaborator was added'
    end

    context 'pagination' do
      background do
        ENV['LOG_ENTRIES_PER_PAGE'] = '8'
        PublicActivity.with_tracking do
          @project.hypotheses << create_list(:hypothesis, 10, project: @project)
        end
        within '#sidebar' do
          click_link 'Activity'
        end
      end

      scenario 'should have 22 activities to work with' do
        activities = PublicActivity::Activity.all
        expect(activities.count).to eq 22
      end

      scenario 'should paginate the log entries in 3 pages' do
        expect(all('#log .log-page').count).to eq 3
      end

      scenario 'should only show the first page at the beginning' do
        expect(all('#log .active.log-page').count).to eq 1
      end

      scenario 'should hide the other 2 pages' do
        expect(all('#log .inactive.log-page').count).to eq 2
      end

      scenario 'should only show 8 entries at first' do
        expect(all('#log .active.log-page .log-entry').count).to eq 8
      end

      scenario 'should hide the other 14 entries' do
        expect(all('#log .inactive.log-page .log-entry').count).to eq 14
      end

      scenario 'should have 8 entries on the second page' do
        expect(
          all('#log .inactive.log-page#log_page_1 .log-entry').count
        ).to eq 8
      end

      scenario 'should only have 6 entries on the third page' do
        expect(
          all('#log .inactive.log-page#log_page_2 .log-entry').count
        ).to eq 6
      end
    end
  end
end
