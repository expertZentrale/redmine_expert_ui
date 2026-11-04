/*
 * redmine_expert_ui - automatic refresh for the issue list and My page.
 *
 * The link comes from a <template>, the settings from a JSON island, both
 * rendered into <head> for signed-in users. A click switches the refresh on or
 * off and stores that per page in the user's preferences (POST); while on, the
 * link counts down and reloads the page at zero.
 *
 * The reload waits while it would destroy something: text being typed, rows
 * selected for a bulk action, an open dialog or context menu. A hidden tab is
 * not reloaded at all until it is shown again.
 */
(function () {
  'use strict';

  var $ = window.jQuery;
  if (!$) { return; }

  var cfg = null;
  var $link = null;
  var deadline = 0;
  var timer = null;
  var due = false;

  function readConfig() {
    var el = document.getElementById('expert-ui-auto-refresh-config');
    if (!el) { return null; }
    try { return JSON.parse(el.textContent); } catch (e) { return null; }
  }

  function csrfToken() {
    var meta = document.querySelector('meta[name="csrf-token"]');
    return meta ? meta.getAttribute('content') : '';
  }

  function remaining() {
    return Math.max(0, Math.ceil((deadline - Date.now()) / 1000));
  }

  function typing() {
    var el = document.activeElement;
    if (!el || el === document.body) { return false; }
    if (el.isContentEditable || el.tagName === 'TEXTAREA' || el.tagName === 'SELECT') { return true; }
    return el.tagName === 'INPUT' && !/^(checkbox|radio|button|submit|reset|hidden|image)$/i.test(el.type);
  }

  function busy() {
    return typing() ||
      $('table.issues input[name="ids[]"]:checked').length > 0 ||
      $('.ui-dialog:visible, #context-menu:visible').length > 0;
  }

  function render() {
    var $label = $link.find('.icon-label');
    if (cfg.enabled) {
      $label.text(cfg.labels.on.replace('%{seconds}', String(remaining())));
      $link.attr({ 'title': cfg.labels.titleOn, 'aria-pressed': 'true' }).addClass('expert-ui-on');
    } else {
      $label.text(cfg.labels.off);
      $link.attr({ 'title': cfg.labels.titleOff, 'aria-pressed': 'false' }).removeClass('expert-ui-on');
    }
  }

  function stop() {
    if (timer) { window.clearInterval(timer); }
    timer = null;
  }

  function restart() {
    stop();
    due = false;
    deadline = Date.now() + cfg.interval * 1000;
    timer = window.setInterval(tick, 1000);
    render();
  }

  function reloadOrWait() {
    if (busy()) { restart(); return; }
    stop();
    window.location.reload();
  }

  // Counts against a deadline rather than per call: background tabs fire
  // timers late, a counter would drift.
  function tick() {
    if (remaining() > 0) { render(); return; }
    if (document.hidden) {
      stop();
      due = true;
      render();
      return;
    }
    reloadOrWait();
  }

  function save() {
    $.ajax({
      url: cfg.url,
      type: 'POST',
      dataType: 'json',
      headers: { 'X-CSRF-Token': csrfToken(), 'Accept': 'application/json' },
      data: { page: cfg.page, enabled: cfg.enabled ? '1' : '0' }
    });
  }

  function init() {
    var template = document.getElementById('expert-ui-auto-refresh-template');
    cfg = readConfig();
    if (!template || !cfg || !document.getElementById('content')) { return; }

    var $bar = $('#content > .contextual').first();
    if (!$bar.length) { $bar = $('<div class="contextual"></div>').prependTo('#content'); }
    $link = $(template.content.querySelector('a').cloneNode(true)).prependTo($bar);

    if (cfg.enabled) { restart(); } else { render(); }

    $link.on('click', function (event) {
      event.preventDefault();
      cfg.enabled = !cfg.enabled;
      if (cfg.enabled) { restart(); } else { stop(); due = false; render(); }
      save();
    });

    document.addEventListener('visibilitychange', function () {
      if (!document.hidden && cfg.enabled && due) { reloadOrWait(); }
    });
  }

  $(init);
})();
