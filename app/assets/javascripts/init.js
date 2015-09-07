ARBOR = {
  common: {
    init: function() {
      $(function() {
        $(document).foundation();
      });
    }
  },
  projects: {},
  canvases: {},
  hypotheses: {},
  user_stories:{}
};

UTIL = {
  exec: function(controller, action) {
    var namespace = ARBOR,
        action = (action === undefined) ? 'init' : action;

    if (controller !== '' && namespace[controller] &&
        typeof namespace[controller][action] == 'function') {
      namespace[controller][action]();
    }
  },

  init: function() {
    var body = document.body,
        controller = body.getAttribute('data-controller'),
        action = body.getAttribute('data-action');

    UTIL.exec('common');
    UTIL.exec(controller);
    UTIL.exec(controller, action);
  }
};

var $projectList = $('#sidebar li .projects-list');

$projectList.click(function() {
  var $this = $(this),
      $parent = $this.closest('ul');

  $parent.toggleClass('active');
  return false;
});

$('#sidebar a').each(function() {
  if ($(this).attr('href')  ===  window.location.pathname) {
    $(this).parent().addClass('selected');
  }
});

$(document).ready(UTIL.init);
