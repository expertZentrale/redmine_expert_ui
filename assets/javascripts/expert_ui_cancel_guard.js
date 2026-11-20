/*
 * redmine_expert_ui - cancel guard for the issue page.
 *
 * Two core links throw away typed text: Cancel under the issue form (it hides
 * the form on the issue page and leaves /issues/:id/edit) and Cancel under an
 * edited note (it removes that form). Both carry inline onclick handlers, so
 * this script listens in the capture phase on the document, which runs before
 * them. When a textarea in that form holds changed text, the click is stopped
 * and the configured style asks first. Once the user agrees, the link is
 * clicked again with the guard out of the way, so core does exactly what it
 * always does.
 *
 * Styles: confirm (dialog), dodge (the link jumps away once or twice), slider
 * (slide to cancel), pour (held down, the link tips over and empties), hold
 * (press and hold), shredder (the text runs through a shredder, Stop! saves
 * it) and random (one of the playful ones each time). With reduced motion
 * asked for, the animated ones fall back to the dialog.
 */
(function () {
  'use strict';

  var PLAYFUL = ['dodge', 'slider', 'pour', 'hold', 'shredder'];
  var ANIMATED = { dodge: true, pour: true, shredder: true };
  var HOLD_MS = 1500;
  var POUR_MS = 2600;
  var SHRED_MS = 3000;
  var SLIDER_IDLE_MS = 5000;
  var DODGE_IDLE_MS = 8000;

  var cfg = null;
  var initial = {};      // issue form textarea id -> value when the page loaded
  var bypass = false;    // set while the agreed Cancel click runs
  var session = null;    // the running challenge
  var swallow = null;    // link whose next click is the tail of a finished hold
  var picked = null;     // {link, style} chosen at the press, kept for its click
  var bubble = null;

  function readConfig() {
    var el = document.getElementById('expert-ui-cancel-guard-config');
    if (!el) { return null; }
    try { return JSON.parse(el.textContent); } catch (e) { return null; }
  }

  function label(key) {
    return (cfg && cfg.labels && cfg.labels[key]) || '';
  }

  function reducedMotion() {
    return !!(window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches);
  }

  function normalize(text) {
    return String(text || '').replace(/\r\n?/g, '\n').replace(/^\s+|\s+$/g, '');
  }

  // --- What counts as typed text ---

  // Core never fills the notes field, so whatever is in it was typed or
  // inserted (reply templates, AI drafts) - even after a failed save, when
  // the server renders the text back. Other issue form fields (description,
  // long text custom fields) compare with their value at page load: Redmine
  // replaces them when the status or tracker changes, and the replacement
  // already carries the typed text as its default. Edited notes compare with
  // the note as it was.
  function initialValue(textarea) {
    if (textarea.id === 'issue_notes') { return ''; }
    if (textarea.form && textarea.form.id === 'issue-form' && textarea.id &&
        Object.prototype.hasOwnProperty.call(initial, textarea.id)) {
      return initial[textarea.id];
    }
    return textarea.defaultValue;
  }

  function changedTextareas(form) {
    return Array.prototype.filter.call(form.querySelectorAll('textarea'), function (textarea) {
      return !textarea.disabled && normalize(textarea.value) !== normalize(initialValue(textarea));
    });
  }

  function rememberIssueForm() {
    var form = document.getElementById('issue-form');
    if (!form) { return; }
    Array.prototype.forEach.call(form.querySelectorAll('textarea[id]'), function (textarea) {
      if (!Object.prototype.hasOwnProperty.call(initial, textarea.id)) { initial[textarea.id] = textarea.defaultValue; }
    });
  }

  // --- Which links are guarded ---

  function guardedLink(target) {
    var link = target && target.closest ? target.closest('a') : null;
    var form = link ? link.closest('form') : null;
    if (!form) { return null; }
    var onclick = link.getAttribute('onclick') || '';
    if (form.id === 'issue-form') {
      var href = link.getAttribute('href') || '';
      if (onclick.indexOf("#update').hide()") !== -1 || (cfg.issuePath && href === cfg.issuePath)) {
        return { link: link, form: form };
      }
    } else if (/^journal-\d+-form$/.test(form.id) && onclick.indexOf('.remove()') !== -1) {
      return { link: link, form: form };
    }
    return null;
  }

  // --- Running a challenge ---

  function pickStyle() {
    var style = cfg.style;
    if (style === 'random') { style = PLAYFUL[Math.floor(Math.random() * PLAYFUL.length)]; }
    if (!STYLES[style]) { style = 'confirm'; }
    if (ANIMATED[style] && reducedMotion()) { style = 'confirm'; }
    return style;
  }

  function start(hit, style) {
    var s = {
      link: hit.link,
      form: hit.form,
      changed: changedTextareas(hit.form),
      done: false,
      cleanup: [],
      onClick: null,
      onEscape: null,
      finish: function (discard) {
        if (s.done) { return; }
        s.done = true;
        if (session === s) { session = null; }
        s.cleanup.slice().reverse().forEach(function (fn) { try { fn(); } catch (e) { /* keep going */ } });
        if (discard) {
          proceed(s.link);
        } else {
          keepWriting(s);
        }
      },
      later: function (fn, ms) {
        var id = window.setTimeout(fn, ms);
        s.cleanup.push(function () { window.clearTimeout(id); });
        return id;
      }
    };
    session = s;
    picked = null;
    STYLES[style](s);
    return s;
  }

  // The agreed Cancel: click the link again and let core handle it.
  function proceed(link) {
    if (!document.documentElement.contains(link)) { return; }
    bypass = true;
    try { link.click(); } finally { bypass = false; }
  }

  function keepWriting(s) {
    var textarea = s.changed[0];
    if (textarea && textarea.offsetParent !== null) {
      try { textarea.focus({ preventScroll: true }); } catch (e) { textarea.focus(); }
    }
  }

  function say(anchor, text, ms) {
    if (bubble) { bubble.remove(); bubble = null; }
    if (!text || !anchor) { return; }
    var el = document.createElement('div');
    el.className = 'expert-ui-cg-bubble';
    el.setAttribute('role', 'status');
    el.textContent = text;
    document.body.appendChild(el);
    var rect = anchor.getBoundingClientRect();
    var left = window.pageXOffset + rect.left + rect.width / 2 - el.offsetWidth / 2;
    left = Math.max(window.pageXOffset + 8, Math.min(left, window.pageXOffset + document.documentElement.clientWidth - el.offsetWidth - 8));
    el.style.left = left + 'px';
    el.style.top = (window.pageYOffset + rect.top - el.offsetHeight - 10) + 'px';
    bubble = el;
    window.setTimeout(function () {
      if (bubble === el) { bubble = null; }
      el.remove();
    }, ms || 1800);
  }

  function make(tag, className, text) {
    var el = document.createElement(tag);
    if (className) { el.className = className; }
    if (text) { el.textContent = text; }
    return el;
  }

  // --- Styles ---

  var STYLES = {};

  // A dialog: "Keep writing" has the focus and answers Escape.
  STYLES.confirm = function (s) {
    var $ = window.jQuery;
    if (!$ || !$.fn || !$.fn.dialog) {
      var discard = window.confirm(label('title') + '\n\n' + label('text'));
      s.finish(discard);
      return;
    }
    var answer = false;
    var $box = $('<div class="expert-ui-cg-dialog"></div>').append($('<p></p>').text(label('text')));
    $box.dialog({
      modal: true,
      resizable: false,
      width: Math.min(420, document.documentElement.clientWidth - 32),
      title: label('title'),
      dialogClass: 'expert-ui-cg-dialog-wrap',
      buttons: [
        { text: label('keep'), 'class': 'expert-ui-cg-keep', click: function () { answer = false; $box.dialog('close'); } },
        { text: label('discard'), 'class': 'expert-ui-cg-discard', click: function () { answer = true; $box.dialog('close'); } }
      ],
      open: function () { $box.parent().find('.expert-ui-cg-keep').trigger('focus'); },
      close: function () {
        $box.dialog('destroy').remove();
        s.finish(answer);
      }
    });
    s.cleanup.push(function () { if ($box.hasClass('ui-dialog-content')) { $box.dialog('destroy').remove(); } });
  };

  // The link jumps away once or twice, then gives in.
  STYLES.dodge = function (s) {
    var link = s.link;
    var jumps = 1 + Math.floor(Math.random() * 2);
    var count = 0;
    var idle = null;
    link.classList.add('expert-ui-cg-dodging');
    var home = link.getBoundingClientRect();
    var taunts = (cfg.labels && cfg.labels.dodge) || [];

    function jump() {
      count += 1;
      var view = document.documentElement;
      var dx = (Math.random() < 0.5 ? -1 : 1) * (60 + Math.random() * 140);
      var dy = (Math.random() < 0.5 ? -1 : 1) * (15 + Math.random() * 45);
      dx = Math.max(8 - home.left, Math.min(dx, view.clientWidth - 8 - home.right));
      dy = Math.max(8 - home.top, Math.min(dy, window.innerHeight - 8 - home.bottom));
      var turn = Math.round((Math.random() - 0.5) * 30);
      link.style.transform = 'translate(' + Math.round(dx) + 'px, ' + Math.round(dy) + 'px) rotate(' + turn + 'deg)';
      var text = count < jumps ? taunts[Math.floor(Math.random() * taunts.length)] : label('dodgeGiveUp');
      window.setTimeout(function () { if (!s.done) { say(link, text, 1600); } }, 280);
      if (idle) { window.clearTimeout(idle); }
      idle = s.later(function () { s.finish(false); }, DODGE_IDLE_MS);
    }

    s.onClick = function () {
      if (count < jumps) { jump(); } else { s.finish(true); }
    };
    s.cleanup.push(function () {
      link.style.transform = '';
      window.setTimeout(function () { link.classList.remove('expert-ui-cg-dodging'); }, 300);
    });
    jump();
  };

  // A slide-to-cancel track replaces the link; letting go early snaps back.
  STYLES.slider = function (s) {
    var link = s.link;
    var wrap = make('span', 'expert-ui-cg-slider');
    var text = make('span', 'expert-ui-cg-slider-label', label('slider'));
    var range = make('input');
    range.type = 'range';
    range.min = '0';
    range.max = '100';
    range.step = '1';
    range.value = '0';
    range.setAttribute('aria-label', label('slider'));
    wrap.appendChild(text);
    wrap.appendChild(range);
    link.classList.add('expert-ui-cg-hidden');
    link.parentNode.insertBefore(wrap, link.nextSibling);
    var idle = null;
    var snapping = null;

    function wait() {
      if (idle) { window.clearTimeout(idle); }
      idle = s.later(function () { s.finish(false); }, SLIDER_IDLE_MS);
    }

    function snapBack() {
      if (snapping) { window.cancelAnimationFrame(snapping); }
      var step = function () {
        var value = Number(range.value);
        if (s.done || value <= 0) { snapping = null; return; }
        range.value = String(Math.max(0, value - 6));
        text.style.opacity = String(1 - Number(range.value) / 100);
        snapping = window.requestAnimationFrame(step);
      };
      snapping = window.requestAnimationFrame(step);
    }

    range.addEventListener('input', function () {
      var value = Number(range.value);
      text.style.opacity = String(1 - value / 100);
      if (snapping) { window.cancelAnimationFrame(snapping); snapping = null; }
      wait();
      if (value >= 95) { s.finish(true); }
    });
    range.addEventListener('change', function () { if (!s.done && Number(range.value) < 95) { snapBack(); } });
    range.addEventListener('pointerup', function () { if (!s.done && Number(range.value) < 95) { snapBack(); } });

    s.outside = wrap;
    s.cleanup.push(function () {
      if (snapping) { window.cancelAnimationFrame(snapping); }
      wrap.remove();
      link.classList.remove('expert-ui-cg-hidden');
    });
    wait();
    range.focus();
  };

  // Press and hold: the challenge runs only while the link is held down (mouse,
  // touch, Enter or Space) and cancels after `ms`; letting go early calls
  // onRelease and nothing is lost. A plain click shows the hint.
  function holdToCancel(s, ms, onPress, onRelease) {
    var timer = null;
    var pressedAt = 0;
    var heldLong = false;
    s.press = function () {
      if (timer || s.done) { return; }
      pressedAt = Date.now();
      onPress();
      timer = window.setTimeout(function () {
        timer = null;
        // The click that follows letting go must not start a new round.
        swallow = s.link;
        window.setTimeout(function () { if (swallow === s.link) { swallow = null; } }, 1000);
        s.finish(true);
      }, ms);
    };
    s.release = function () {
      if (!timer) { return; }
      window.clearTimeout(timer);
      timer = null;
      heldLong = Date.now() - pressedAt > 400;
      onRelease(heldLong);
    };
    // A short press ends in a click: explain. After a longer hold the release
    // already said what happened.
    s.onClick = function () {
      if (!heldLong) { say(s.link, s.hint, 1800); }
      heldLong = false;
    };
    s.cleanup.push(function () { if (timer) { window.clearTimeout(timer); } });
  }

  // The link becomes a full glass. Held down, it tips over and runs dry;
  // let go early and it stands up again with the text kept.
  STYLES.pour = function (s) {
    var link = s.link;
    var liquid = make('span', 'expert-ui-cg-liquid');
    link.classList.add('expert-ui-cg-glass');
    link.appendChild(liquid);
    // The stream and the puddle stay upright, so they live outside the glass:
    // tipped over its bottom right corner, the rim ends up about one glass
    // height to the right of that corner.
    var rect = link.getBoundingClientRect();
    var spill = make('span', 'expert-ui-cg-spill');
    spill.style.left = (window.pageXOffset + rect.right + rect.height * 0.8) + 'px';
    spill.style.top = (window.pageYOffset + rect.bottom) + 'px';
    for (var i = 0; i < 7; i += 1) {
      var drop = make('i', 'expert-ui-cg-drop');
      drop.style.animationDelay = (0.5 + i * 0.27) + 's';
      drop.style.left = Math.round((Math.random() - 0.5) * 6) + 'px';
      spill.appendChild(drop);
    }
    spill.appendChild(make('span', 'expert-ui-cg-puddle'));
    document.body.appendChild(spill);
    s.hint = label('pourHint');
    s.capture = true;

    holdToCancel(s, POUR_MS, function () {
      link.classList.add('expert-ui-cg-pouring');
      spill.classList.add('expert-ui-cg-pouring');
      say(link, label('pour'), POUR_MS);
    }, function () {
      link.classList.remove('expert-ui-cg-pouring');
      spill.classList.remove('expert-ui-cg-pouring');
      say(link, label('saved'), 1600);
    });
    s.cleanup.push(function () {
      link.classList.remove('expert-ui-cg-pouring', 'expert-ui-cg-glass');
      liquid.remove();
      spill.remove();
    });
  };

  // Press and hold the link until the bar is full; letting go early resets it.
  STYLES.hold = function (s) {
    var link = s.link;
    var bar = make('span', 'expert-ui-cg-hold-bar');
    link.classList.add('expert-ui-cg-hold');
    link.appendChild(bar);
    s.hint = label('hold');

    holdToCancel(s, HOLD_MS, function () {
      link.classList.add('expert-ui-cg-holding');
    }, function () {
      link.classList.remove('expert-ui-cg-holding');
    });
    s.cleanup.push(function () {
      link.classList.remove('expert-ui-cg-hold', 'expert-ui-cg-holding');
      bar.remove();
    });
  };

  // The text runs through a shredder over the textarea; Stop! saves it.
  STYLES.shredder = function (s) {
    var textarea = s.changed.filter(function (t) { return t.offsetParent !== null; })[0];
    if (!textarea) { STYLES.confirm(s); return; }
    var rect = textarea.getBoundingClientRect();
    var look = window.getComputedStyle(textarea);
    var box = make('div', 'expert-ui-cg-shredder');
    box.style.left = (window.pageXOffset + rect.left) + 'px';
    box.style.top = (window.pageYOffset + rect.top) + 'px';
    box.style.width = rect.width + 'px';
    box.style.height = rect.height + 'px';
    box.appendChild(make('div', 'expert-ui-cg-blade'));
    var paper = make('div', 'expert-ui-cg-paper');
    var strips = 14;
    var content = textarea.value.slice(0, 3000);
    for (var i = 0; i < strips; i += 1) {
      var strip = make('div', 'expert-ui-cg-strip', content);
      strip.style.fontFamily = look.fontFamily;
      strip.style.fontSize = look.fontSize;
      strip.style.lineHeight = look.lineHeight;
      strip.style.color = look.color;
      strip.style.backgroundColor = look.backgroundColor;
      strip.style.padding = look.padding;
      strip.style.clipPath = 'inset(0 ' + (100 - (i + 1) * 100 / strips) + '% 0 ' + (i * 100 / strips) + '%)';
      strip.style.animationDelay = (0.25 + Math.random() * 0.9).toFixed(2) + 's';
      strip.style.setProperty('--expert-ui-cg-drift', Math.round((Math.random() - 0.5) * 40) + 'px');
      strip.style.setProperty('--expert-ui-cg-turn', Math.round((Math.random() - 0.5) * 24) + 'deg');
      paper.appendChild(strip);
    }
    box.appendChild(paper);
    var panel = make('div', 'expert-ui-cg-shredder-panel');
    panel.appendChild(make('span', 'expert-ui-cg-shredder-label', label('shredder')));
    var stop = make('button', 'expert-ui-cg-stop', label('stop'));
    stop.type = 'button';
    stop.addEventListener('click', function (event) {
      event.preventDefault();
      s.finish(false);
      say(textarea, label('saved'), 1600);
    });
    panel.appendChild(stop);
    box.appendChild(panel);
    document.body.appendChild(box);
    textarea.style.visibility = 'hidden';
    stop.focus({ preventScroll: true });

    s.outside = box;
    s.onClick = function () { s.finish(false); say(textarea, label('saved'), 1600); };
    s.cleanup.push(function () {
      textarea.style.visibility = '';
      box.remove();
    });
    s.later(function () { s.finish(true); }, SHRED_MS);
  };

  // --- Wiring ---

  document.addEventListener('click', function (event) {
    if (bypass || !cfg) { return; }
    var hit = guardedLink(event.target);
    if (swallow && hit && hit.link === swallow) {
      swallow = null;
      event.preventDefault();
      event.stopImmediatePropagation();
      return;
    }
    if (session && !session.done) {
      if (hit && hit.link === session.link) {
        event.preventDefault();
        event.stopImmediatePropagation();
        if (session.onClick) { session.onClick(); }
        return;
      }
      // A click elsewhere ends the challenge, the text stays.
      if (!(session.outside && session.outside.contains(event.target)) &&
          !(event.target.closest && event.target.closest('.ui-dialog'))) {
        session.finish(false);
      }
    }
    if (!hit || changedTextareas(hit.form).length === 0) { return; }
    event.preventDefault();
    event.stopImmediatePropagation();
    var s = start(hit, styleFor(hit));
    if (s.press) { say(s.link, s.hint, 1800); }
  }, true);

  // The style for this attempt, chosen once: the press (pointer or key) comes
  // before the click, and with 'random' both must see the same choice.
  function styleFor(hit) {
    if (!picked || picked.link !== hit.link) { picked = { link: hit.link, style: pickStyle() }; }
    return picked.style;
  }

  function pressStyle(style) {
    return style === 'hold' || style === 'pour';
  }

  // Hold and pour: pressing the link starts them, even as the very first
  // action and with 'random' picking one of them.
  document.addEventListener('pointerdown', function (event) {
    if (!cfg || event.button !== 0) { return; }
    var hit = guardedLink(event.target);
    if (!hit) { return; }
    if (swallow === hit.link) { swallow = null; }
    if (!session && changedTextareas(hit.form).length > 0 && pressStyle(styleFor(hit))) {
      start(hit, styleFor(hit));
    }
    if (session && session.link === hit.link && session.press) {
      session.press();
      // The tipping glass moves away under the pointer; capturing keeps the
      // press on the link until the button goes up.
      if (session.capture && hit.link.setPointerCapture) {
        try { hit.link.setPointerCapture(event.pointerId); } catch (e) { /* not capturable */ }
      }
    }
  }, true);

  ['pointerup', 'pointercancel'].forEach(function (type) {
    document.addEventListener(type, function () { if (session && session.release) { session.release(); } }, true);
  });
  document.addEventListener('pointerout', function (event) {
    if (session && session.release && session.link.contains(event.target) &&
        !session.link.contains(event.relatedTarget)) {
      session.release();
    }
  }, true);

  document.addEventListener('keydown', function (event) {
    if (!cfg) { return; }
    if (session && !session.done && (event.key === 'Escape' || event.key === 'Esc')) {
      session.finish(false);
      return;
    }
    if (event.key !== 'Enter' && event.key !== ' ') { return; }
    var hit = guardedLink(event.target);
    if (!hit || hit.link !== event.target) { return; }
    // Hold with Enter or Space on the focused link, from the first key press
    // on; the click Enter would trigger at once is prevented.
    if (!session && !event.repeat && changedTextareas(hit.form).length > 0 && pressStyle(styleFor(hit))) {
      start(hit, styleFor(hit));
    }
    if (session && !session.done && session.press && session.link === hit.link) {
      event.preventDefault();
      event.stopImmediatePropagation();
      if (!event.repeat) { session.press(); }
    }
  }, true);
  document.addEventListener('keyup', function (event) {
    if (session && session.release && event.target === session.link && (event.key === 'Enter' || event.key === ' ')) {
      session.release();
    }
  }, true);

  // Saving the form ends any challenge without cancelling.
  document.addEventListener('submit', function () { if (session) { session.finish(false); } }, true);

  function init() {
    cfg = readConfig();
    rememberIssueForm();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
