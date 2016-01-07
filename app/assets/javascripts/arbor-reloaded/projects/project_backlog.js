var commonGrowInputOptions = { minWidth: 180, maxWidth: 600, comfortZone: 30 },
    $backlogStoryList      = $('.backlog-story-list'),
    $storyModal            = $('#story-detail-modal'),
    $storyBulkInput        = $backlogStoryList.find('.circle-checkbox'),
    $bulkMenu              = $backlogStoryList.find('.sticky-menu');

// Attach autogrow on form submit, Ale
$('#new_user_story').submit(function() {
  autogrowInputs();
});

function autogrowInputs() {
  $('#role-input').trigger('autogrow');
  $('#action-input').trigger('autogrow');
  $('#result-input').trigger('autogrow');
}

function bindReorderStories() {
  $('.backlog-story-list').sortable({
    connectWith: '.backlog-story-list',
    stop: function() {
      var newStoriesOrder = setStoriesOrder(),
          url = $('.backlog-story-list').data('url');
          project = $('.backlog-story-list').data('project');
      $.ajax({
        url: url,
        dataType: 'json',
        method: 'PUT',
        data: { stories: newStoriesOrder.stories, project: project }
      });
    }
  });
}

function setStoriesOrder() {
  var newStoriesOrder = { stories: [] },
      $updatedStoriesOnList = $('li.backlog-user-story');

  $.each($updatedStoriesOnList, function(index) {
    var story = { id: $(this).data('id'), backlog_order: index + 1 };
    newStoriesOrder.stories.push(story);
  });

  return newStoriesOrder;
}

function showBulkMenu() {
  $storyBulkInput.click(function() {
    $bulkMenu[$storyBulkInput.is(':checked') ? "show" : "hide"]();
  });
}

function showModalStoryDropdown() {
  var $storyActions = $storyModal.find('.story-actions'),
      $trigger      = $storyActions.find('.story-actions-link'),
      $actions      = $storyActions.find('a').not($trigger);

  $trigger.click(function() {
    $(this).addClass('open');
    $actions.addClass('active');
    return false;
  });

  $('html').click(function() {
    if ($trigger.hasClass('open')) {
      $trigger.removeClass('open');
      $actions.removeClass('active');
    }
  });
}//show actions dropwdon on modal

$(document).ready(function() {
  if ($('.new-backlog-story').length > 0) {
    $('#role-input').autoGrowInput(commonGrowInputOptions);
    $('#action-input').autoGrowInput(commonGrowInputOptions);
    $('#result-input').autoGrowInput(commonGrowInputOptions);
    autogrowInputs();
  }

  if ($backlogStoryList.length) {
    showBulkMenu();
    bindReorderStories();
  }
  
  $storyModal.on('opened.fndtn.reveal', function() {
    showModalStoryDropdown();
  });
});
