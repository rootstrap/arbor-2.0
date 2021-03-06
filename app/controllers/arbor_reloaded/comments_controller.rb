module ArborReloaded
  class CommentsController < ApplicationController
    before_action :set_user_story, only: [:create]

    def create
      @comment =
        Comment.new(comment: comment_params[:comment], user: current_user)
      @user_story.comments << @comment
      create_resources(@comment) if @comment.save
      slack_notification
    end

    def destroy
      comment = current_user.comments.find(params[:id])
      @user_story = comment.user_story
      comment.destroy
    end

    private

    def create_resources(comment)
      @user_story.project.create_activity :add_comment,
      owner: current_user,
      parameters:
        { user_story: @user_story.log_description,
          comment: comment.comment }
      ArborReloaded::IntercomServices
        .new(current_user).create_event(t('intercom_keys.create_comment'))
    end

    def comment_params
      params.require(:comment).permit(:comment, :user_story_id)
    end

    def set_user_story
      @user_story =
        @comment.try(:user_story) ||
        UserStory.find(params[:user_story_id])
    end

    def slack_notification
      project = @user_story.project
      return unless project.slack_iw_url
      ArborReloaded::SlackIntegrationService.new(project)
        .comment_notify(@user_story.id, @comment.comment)
    end
  end
end
