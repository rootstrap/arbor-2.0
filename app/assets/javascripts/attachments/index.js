var selector_link       = $('.attachment-selector a#attachment-switcher'),
    switch_to_file_text = I18n.t('attachment.selector_file'),
    switch_to_link_text = I18n.t('attachment.selector_link');

selector_link.click(function() {
  var attachments = $('.attachment-new #new_link, #new_file');
  attachments.toggleClass('active inactive');

  if ($('#new_link.active').length) {
    selector_link.text(switch_to_file_text);
  } else {
    selector_link.text(switch_to_link_text);
  }
});

var file_selector = $('#new_file input#attachment_content');
file_selector.change(function() {
  var filename = file_selector.val().replace(/^.*(\\|\/|\:)/, '');;
  $('#new_file .image-uploader span').text(filename);
});

