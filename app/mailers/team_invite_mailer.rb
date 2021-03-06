class TeamInviteMailer < BaseMailer
  def team_invite_email(data)
    @team_name = data[:team_name]

    attachments.inline['logo.png'] = File.read(
      File.join Rails.root, 'public', 'arbor-logo.png'
    )

    mail to: data[:email], subject: t('mailer.invite.subject')
  end
end
