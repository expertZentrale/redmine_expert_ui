/*
 * redmine_expert_ui - close button on the issue page.
 *
 * The server renders the button (in a <template>) and the status it sets (JSON
 * island) only when the user may close the issue. Here the button goes into
 * each action bar of the issue page, in front of the "..." menu. A click sets
 * the status and % Done in the issue's edit form and submits that form, so
 * notes typed into it are saved along.
 */
(function () {
  'use strict';

  var $ = window.jQuery;
  if (!$) { return; }

  function config() {
    var el = document.querySelector('script.expert-ui-close-button-config');
    if (!el) { return null; }
    try { return JSON.parse(el.textContent); } catch (e) { return null; }
  }

  function hasOption($select, value) {
    return $select.find('option').filter(function () { return this.value === value; }).length > 0;
  }

  function init() {
    var template = document.querySelector('template.expert-ui-close-button-template');
    if (!template || !config() || !document.getElementById('issue-form')) { return; }
    var button = template.content.querySelector('a');
    // The action bars are the ones with the edit link (top and bottom).
    $('#content > .contextual').has('a.icon-edit').each(function () {
      if ($(this).find('.expert-ui-close-button').length) { return; }
      var $button = $(button.cloneNode(true));
      var $menu = $(this).children('.drdn').first();
      if ($menu.length) { $button.insertBefore($menu); } else { $(this).append($button); }
    });
  }

  $(document).on('click', '.expert-ui-close-button', function (event) {
    event.preventDefault();
    var cfg = config();
    var $form = $('#issue-form');
    var $status = $('#issue_status_id');
    if (!cfg || !$form.length || $(this).hasClass('disabled')) { return; }

    var status = String(cfg.statusId);
    if (!$status.length || !hasOption($status, status)) {
      // The form does not offer the status (read-only field, or the issue
      // changed meanwhile): open it so the user sees what is possible.
      if (typeof window.showAndScrollTo === 'function') { window.showAndScrollTo('update', 'issue_notes'); }
      return;
    }
    $status.val(status);

    var $ratio = $('#issue_done_ratio');
    var ratio = String(cfg.doneRatio);
    if (cfg.doneRatio !== null && $ratio.length && !$ratio.prop('disabled') && hasOption($ratio, ratio)) {
      $ratio.val(ratio);
    }

    $('.expert-ui-close-button').addClass('disabled').attr('aria-disabled', 'true');
    // Through jQuery, so other submit handlers (unsaved-changes warning,
    // plugins) still run before the browser sends the form.
    $form.trigger('submit');
  });

  $(init);
})();
