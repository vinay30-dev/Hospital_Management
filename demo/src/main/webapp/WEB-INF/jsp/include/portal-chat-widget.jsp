<%@ page trimDirectiveWhitespaces="true" pageEncoding="UTF-8" %>
<%--
  portal-chat-widget.jsp
  Floating help chat — POST ${initParam.nodeApiBase}/api/chat

  All widget CSS is inlined here (not split into portal-chat-widget.css)
  so it is guaranteed to parse before the JS creates DOM nodes.
  The shell (#hm-portal-chat) is appended via DOMContentLoaded so it is
  never a flex/grid child of login.jsp / register.jsp body layouts.
--%>

<%-- ═══ SCOPED STYLES — all scoped to #hm-portal-chat ═════════════ --%>
<style>
#hm-portal-chat {
  /* Design tokens — match portal.css / login.jsp */
  --pc-navy:        #0b1628;
  --pc-teal:        #0ee8c4;
  --pc-teal-dim:    rgba(14,232,196,.10);
  --pc-teal-glow:   rgba(14,232,196,.32);
  --pc-teal-border: rgba(14,232,196,.22);
  --pc-slate:       #8892b0;
  --pc-light:       #ccd6f6;
  --pc-card-bg:     rgba(17,34,64,.94);
  --pc-input-bg:    rgba(11,22,40,.88);
  --pc-border:      rgba(136,146,176,.22);
  --pc-radius:      14px;
  --pc-fab:         56px;
  --pc-w:           360px;
  --pc-h:           min(520px, calc(100vh - 120px));
  --pc-ease:        cubic-bezier(.16,1,.3,1);
  --pc-shadow:      0 24px 60px rgba(0,0,0,.55),
                    0 0 0 1px rgba(255,255,255,.04) inset;
  --pc-fab-shadow:  0 4px 20px var(--pc-teal-glow), 0 2px 8px rgba(0,0,0,.4);

  /* Critical: force this element out of every possible layout context */
  position: fixed !important;
  top:    0 !important;
  right:  0 !important;
  bottom: 0 !important;
  left:   0 !important;
  width:  100% !important;
  height: 100% !important;
  z-index: 9999 !important;
  pointer-events: none !important;
  /* Undo flex-child sizing */
  flex:       none !important;
  flex-grow:  0    !important;
  flex-shrink:0    !important;
  align-self: auto !important;
  max-width:  none !important;
  max-height: none !important;
  /* No box model bleed */
  margin:  0 !important;
  padding: 0 !important;
  border:  none !important;
  background: transparent !important;
  overflow: visible !important;
}

/* ── FAB ──────────────────────────────────────────────────────────── */
#hm-portal-chat .portal-chat-fab {
  position: absolute;
  bottom: 28px;
  right:  28px;
  z-index: 2;
  pointer-events: auto;
  width:  var(--pc-fab);
  height: var(--pc-fab);
  border-radius: 50%;
  border: 1.5px solid var(--pc-teal-border);
  background: linear-gradient(135deg, var(--pc-teal), #0acfb1);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: var(--pc-fab-shadow);
  transition: transform .2s var(--pc-ease), box-shadow .2s;
  padding: 0; margin: 0;
  -webkit-appearance: none; appearance: none;
  outline: none;
}
#hm-portal-chat .portal-chat-fab:hover {
  transform: scale(1.06) translateY(-2px);
  box-shadow: 0 8px 28px var(--pc-teal-glow), 0 2px 10px rgba(0,0,0,.45);
}
#hm-portal-chat .portal-chat-fab:active { transform: scale(.96); }
#hm-portal-chat .portal-chat-fab:focus-visible {
  outline: 2px solid var(--pc-teal);
  outline-offset: 3px;
}
#hm-portal-chat .portal-chat-fab svg {
  width: 24px; height: 24px;
  fill: var(--pc-navy);
  display: block;
}
/* Pulse ring */
#hm-portal-chat .portal-chat-fab::after {
  content: '';
  position: absolute;
  inset: -4px;
  border-radius: 50%;
  border: 2px solid var(--pc-teal);
  opacity: 0;
  animation: hm-pc-pulse 2.8s ease-in-out infinite;
  pointer-events: none;
}
#hm-portal-chat .portal-chat-fab[aria-expanded="true"]::after { animation: none; }
@keyframes hm-pc-pulse {
  0%,100% { transform: scale(1);    opacity: 0; }
  50%      { transform: scale(1.22); opacity: .28; }
}

/* ── PANEL ────────────────────────────────────────────────────────── */
#hm-portal-chat .portal-chat-panel {
  position: absolute;
  bottom: calc(var(--pc-fab) + 36px);
  right: 28px;
  z-index: 1;
  pointer-events: auto;
  width: var(--pc-w);
  max-width: calc(100vw - 40px);
  height: var(--pc-h);
  display: flex;
  flex-direction: column;
  border-radius: var(--pc-radius);
  border: 1px solid var(--pc-teal-border);
  background: var(--pc-card-bg);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  box-shadow: var(--pc-shadow);
  overflow: hidden;
  transform-origin: bottom right;
}
#hm-portal-chat .portal-chat-panel[hidden] {
  display: none !important;
}
#hm-portal-chat .portal-chat-panel:not([hidden]) {
  animation: hm-pc-panel-in .28s var(--pc-ease) both;
}
@keyframes hm-pc-panel-in {
  from { opacity: 0; transform: scale(.94) translateY(12px); }
  to   { opacity: 1; transform: none; }
}

/* ── HEADER ───────────────────────────────────────────────────────── */
#hm-portal-chat .portal-chat-head {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 13px 15px 12px;
  border-bottom: 1px solid var(--pc-teal-border);
  background: rgba(11,22,40,.55);
  flex-shrink: 0;
}
#hm-portal-chat .portal-chat-head-logo {
  width: 32px; height: 32px;
  border-radius: 9px;
  background: linear-gradient(135deg, var(--pc-teal), #3b82f6);
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
  font-family: 'Playfair Display', Georgia, serif;
  font-size: 12px; font-weight: 700;
  color: var(--pc-navy);
}
#hm-portal-chat .portal-chat-head-text { flex: 1; min-width: 0; }
#hm-portal-chat .portal-chat-title {
  font-family: 'Playfair Display', Georgia, serif;
  font-size: 15px; font-weight: 600;
  color: var(--pc-light);
  margin: 0; line-height: 1.2;
}
#hm-portal-chat .portal-chat-online {
  font-family: 'DM Sans', system-ui, sans-serif;
  font-size: 11px; color: var(--pc-teal);
  display: flex; align-items: center; gap: 5px;
  margin-top: 2px;
}
#hm-portal-chat .portal-chat-online::before {
  content: '';
  width: 6px; height: 6px; border-radius: 50%;
  background: var(--pc-teal);
  box-shadow: 0 0 6px var(--pc-teal);
  flex-shrink: 0;
}
#hm-portal-chat .portal-chat-close {
  width: 32px; height: 32px;
  border-radius: 8px;
  border: 1px solid var(--pc-border);
  background: rgba(136,146,176,.08);
  color: var(--pc-slate);
  cursor: pointer;
  display: flex; align-items: center; justify-content: center;
  transition: background .15s, color .15s, border-color .15s;
  flex-shrink: 0;
  padding: 0; margin: 0;
  -webkit-appearance: none; appearance: none;
}
#hm-portal-chat .portal-chat-close:hover {
  background: rgba(14,232,196,.12);
  border-color: var(--pc-teal-border);
  color: var(--pc-teal);
}
#hm-portal-chat .portal-chat-close svg {
  width: 16px; height: 16px; display: block;
}

/* ── MESSAGE LOG ──────────────────────────────────────────────────── */
#hm-portal-chat .portal-chat-log {
  flex: 1; min-height: 0;
  overflow-y: auto;
  padding: 16px 14px;
  display: flex; flex-direction: column; gap: 10px;
  scroll-behavior: smooth;
}
#hm-portal-chat .portal-chat-log::-webkit-scrollbar { width: 4px; }
#hm-portal-chat .portal-chat-log::-webkit-scrollbar-thumb {
  background: rgba(14,232,196,.25); border-radius: 4px;
}
#hm-portal-chat .portal-chat-msg {
  font-family: 'DM Sans', system-ui, sans-serif;
  font-size: 13.5px; line-height: 1.55;
  max-width: 86%;
  padding: 9px 13px; border-radius: 12px;
  animation: hm-pc-msg-in .22s var(--pc-ease) both;
  word-break: break-word;
}
@keyframes hm-pc-msg-in {
  from { opacity: 0; transform: translateY(6px); }
  to   { opacity: 1; transform: none; }
}
#hm-portal-chat .portal-chat-msg.bot {
  align-self: flex-start;
  background: rgba(14,232,196,.08);
  border: 1px solid var(--pc-teal-border);
  color: var(--pc-light);
  border-bottom-left-radius: 4px;
}
#hm-portal-chat .portal-chat-msg.user {
  align-self: flex-end;
  background: linear-gradient(135deg, var(--pc-teal), #0acfb1);
  color: var(--pc-navy);
  font-weight: 500;
  border-bottom-right-radius: 4px;
}
#hm-portal-chat .portal-chat-msg.err {
  align-self: flex-start;
  background: rgba(220,53,69,.12);
  border: 1px solid rgba(220,53,69,.28);
  color: #ff8a8a;
  font-size: 13px;
  border-bottom-left-radius: 4px;
}

/* Typing dots */
#hm-portal-chat .portal-chat-typing {
  align-self: flex-start;
  display: flex; align-items: center; gap: 4px;
  padding: 10px 14px;
  background: rgba(14,232,196,.06);
  border: 1px solid var(--pc-teal-border);
  border-radius: 12px 12px 12px 4px;
}
#hm-portal-chat .portal-chat-typing span {
  width: 6px; height: 6px; border-radius: 50%;
  background: var(--pc-teal); opacity: .35;
  animation: hm-pc-bounce .9s ease-in-out infinite;
}
#hm-portal-chat .portal-chat-typing span:nth-child(2) { animation-delay: .15s; }
#hm-portal-chat .portal-chat-typing span:nth-child(3) { animation-delay: .30s; }
@keyframes hm-pc-bounce {
  0%,80%,100% { transform: translateY(0);   opacity: .35; }
  40%          { transform: translateY(-5px); opacity: 1;   }
}

/* ── FOOTER ───────────────────────────────────────────────────────── */
#hm-portal-chat .portal-chat-foot {
  flex-shrink: 0;
  padding: 11px 14px 14px;
  border-top: 1px solid var(--pc-teal-border);
  background: rgba(11,22,40,.55);
}
#hm-portal-chat .portal-chat-form {
  display: flex; gap: 8px; align-items: stretch;
}
/* Fully isolated input — defeats Bootstrap reboot & portal-page overrides */
#hm-portal-chat input.portal-chat-input {
  flex: 1; min-width: 0;
  box-sizing: border-box !important;
  -webkit-appearance: none; appearance: none;
  display: block !important;
  background: var(--pc-input-bg) !important;
  border: 1px solid var(--pc-border) !important;
  border-radius: 10px !important;
  color: var(--pc-light) !important;
  font-family: 'DM Sans', system-ui, sans-serif !important;
  font-size: 14px !important;
  line-height: 1.4 !important;
  padding: 10px 13px !important;
  margin: 0 !important;
  width: auto !important;
  height: auto !important;
  max-width: none !important;
  transition: border-color .2s, box-shadow .2s;
  outline: none !important;
  box-shadow: none !important;
}
#hm-portal-chat input.portal-chat-input::placeholder {
  color: rgba(136,146,176,.5) !important;
}
#hm-portal-chat input.portal-chat-input:focus {
  border-color: var(--pc-teal) !important;
  box-shadow: 0 0 0 3px var(--pc-teal-dim) !important;
}
#hm-portal-chat .portal-chat-send {
  flex-shrink: 0;
  width: 44px; min-height: 44px;
  border-radius: 10px;
  border: none !important;
  background: linear-gradient(135deg, var(--pc-teal), #0acfb1) !important;
  color: var(--pc-navy) !important;
  cursor: pointer;
  display: flex; align-items: center; justify-content: center;
  box-shadow: 0 4px 14px var(--pc-teal-glow);
  transition: transform .15s, box-shadow .2s, opacity .15s;
  padding: 0; margin: 0;
  -webkit-appearance: none; appearance: none;
}
#hm-portal-chat .portal-chat-send:hover {
  transform: translateY(-1px);
  box-shadow: 0 6px 20px var(--pc-teal-glow);
}
#hm-portal-chat .portal-chat-send:active  { transform: scale(.96); }
#hm-portal-chat .portal-chat-send:disabled {
  opacity: .45; cursor: not-allowed; transform: none; box-shadow: none;
}
#hm-portal-chat .portal-chat-send svg {
  width: 18px; height: 18px; fill: var(--pc-navy); display: block;
}
#hm-portal-chat .portal-chat-hint {
  font-family: 'DM Sans', system-ui, sans-serif;
  font-size: 11px;
  color: rgba(136,146,176,.48);
  margin: 8px 0 0;
  text-align: center;
  line-height: 1.45;
}

/* Screen-reader label */
.hm-pc-sr-only {
  position: absolute; width: 1px; height: 1px;
  padding: 0; margin: -1px; overflow: hidden;
  clip: rect(0,0,0,0); white-space: nowrap; border: 0;
}

/* ── Mobile ───────────────────────────────────────────────────────── */
@media (max-width: 480px) {
  #hm-portal-chat .portal-chat-panel:not([hidden]) {
    left: 10px; right: 10px;
    bottom: calc(var(--pc-fab) + 16px);
    width: auto; max-width: none;
    height: min(70vh, 520px);
  }
  #hm-portal-chat .portal-chat-fab {
    bottom: 18px; right: 18px;
  }
}
</style>

<%-- ═══ SCRIPT — inject DOM after page is ready ════════════════════ --%>
<script>
(function () {
  'use strict';

  function buildWidget() {
    /* Guard: don't double-inject */
    if (document.getElementById('hm-portal-chat')) return;

    /* ── Build shell ── */
    var shell = document.createElement('div');
    shell.id = 'hm-portal-chat';
    shell.setAttribute('aria-live', 'polite');
    shell.innerHTML =
      '<button type="button" class="portal-chat-fab" id="portal-chat-fab"' +
      '        aria-expanded="false" aria-controls="portal-chat-panel"' +
      '        title="Hospital help chat">' +
      '  <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">' +
      '    <path d="M20 2H4C2.897 2 2 2.897 2 4v13c0 1.103.897 2 2 2h3v3.586' +
      '             L11.707 19H20c1.103 0 2-.897 2-2V4c0-1.103-.897-2-2-2z' +
      '             m-6 11H7v-2h7v2zm3-4H7V7h10v2z"/>' +
      '  </svg>' +
      '</button>' +

      '<div id="portal-chat-panel" class="portal-chat-panel"' +
      '     role="dialog" aria-modal="true"' +
      '     aria-labelledby="portal-chat-title" hidden>' +

      '  <div class="portal-chat-head">' +
      '    <div class="portal-chat-head-logo" aria-hidden="true">HM</div>' +
      '    <div class="portal-chat-head-text">' +
      '      <h2 class="portal-chat-title" id="portal-chat-title">Hospital Help</h2>' +
      '      <div class="portal-chat-online">Online \u00b7 Demo assistant</div>' +
      '    </div>' +
      '    <button type="button" class="portal-chat-close" id="portal-chat-close"' +
      '            aria-label="Close chat">' +
      '      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"' +
      '           stroke-width="2" stroke-linecap="round"' +
      '           xmlns="http://www.w3.org/2000/svg" aria-hidden="true">' +
      '        <path d="M18 6L6 18M6 6l12 12"/>' +
      '      </svg>' +
      '    </button>' +
      '  </div>' +

      '  <div class="portal-chat-log" id="portal-chat-log"' +
      '       role="log" aria-label="Chat messages"></div>' +

      '  <div class="portal-chat-foot">' +
      '    <form class="portal-chat-form" id="portal-chat-form"' +
      '          autocomplete="off" novalidate>' +
      '      <label class="hm-pc-sr-only" for="portal-chat-input">Type your message</label>' +
      '      <input class="portal-chat-input" type="text"' +
      '             id="portal-chat-input" name="message"' +
      '             maxlength="2000" placeholder="Ask about hours, booking\u2026"' +
      '             autocomplete="off"/>' +
      '      <button type="submit" class="portal-chat-send"' +
      '              id="portal-chat-send" aria-label="Send message">' +
      '        <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">' +
      '          <path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z"/>' +
      '        </svg>' +
      '      </button>' +
      '    </form>' +
      '    <p class="portal-chat-hint">' +
      '      Demo assistant \u2014 not for personal health data or emergencies.' +
      '    </p>' +
      '  </div>' +
      '</div>';

    /* Append to body LAST — completely outside any flex/grid flow */
    document.body.appendChild(shell);

    /* ── Wire behaviour ── */
    var API_BASE = '${initParam.nodeApiBase}';
    var CHAT_URL = API_BASE.replace(/\/$/, '') + '/api/chat';

    var fab      = document.getElementById('portal-chat-fab');
    var panel    = document.getElementById('portal-chat-panel');
    var closeBtn = document.getElementById('portal-chat-close');
    var logEl    = document.getElementById('portal-chat-log');
    var form     = document.getElementById('portal-chat-form');
    var input    = document.getElementById('portal-chat-input');
    var sendBtn  = document.getElementById('portal-chat-send');

    function appendMsg(text, cls) {
      var div = document.createElement('div');
      div.className = 'portal-chat-msg ' + cls;
      div.textContent = text;
      logEl.appendChild(div);
      logEl.scrollTop = logEl.scrollHeight;
    }

    function showTyping() {
      var el = document.createElement('div');
      el.className = 'portal-chat-typing';
      el.id = 'pc-typing';
      el.setAttribute('aria-label', 'Assistant is typing');
      el.innerHTML = '<span></span><span></span><span></span>';
      logEl.appendChild(el);
      logEl.scrollTop = logEl.scrollHeight;
    }

    function removeTyping() {
      var el = document.getElementById('pc-typing');
      if (el) el.remove();
    }

    function setOpen(open) {
      panel.hidden = !open;
      fab.setAttribute('aria-expanded', open ? 'true' : 'false');
      if (open) {
        input.focus();
        if (!logEl.querySelector('.portal-chat-msg')) {
          appendMsg(
            'Hi \u2014 ask about hours, booking appointments, or who to contact.',
            'bot'
          );
        }
      }
    }

    fab.addEventListener('click', function () { setOpen(panel.hidden); });
    closeBtn.addEventListener('click', function () { setOpen(false); fab.focus(); });
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && !panel.hidden) { setOpen(false); fab.focus(); }
    });

    form.addEventListener('submit', async function (e) {
      e.preventDefault();
      var msg = (input.value || '').trim();
      if (!msg) return;

      appendMsg(msg, 'user');
      input.value = '';
      sendBtn.disabled = true;
      showTyping();

      try {
        var res = await fetch(CHAT_URL, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ message: msg }),
          credentials: 'omit'
        });
        var data = await res.json().catch(function () { return {}; });
        removeTyping();
        if (!res.ok) {
          appendMsg(data.message || ('Request failed (' + res.status + ')'), 'err');
          return;
        }
        appendMsg(
          typeof data.reply === 'string' ? data.reply : 'Unexpected response.',
          typeof data.reply === 'string' ? 'bot' : 'err'
        );
      } catch (err) {
        removeTyping();
        appendMsg(
          'Could not reach the help service. Is the Node API running on port 3001?',
          'err'
        );
      } finally {
        sendBtn.disabled = false;
        input.focus();
      }
    });
  }

  /* Run after full DOM is ready — guarantees body exists and
     all page CSS (including login.jsp's flex body) has been applied,
     so appendChild places the shell outside the flex container cleanly. */
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', buildWidget);
  } else {
    buildWidget(); /* already ready (script runs after </body>) */
  }

})();
</script>
