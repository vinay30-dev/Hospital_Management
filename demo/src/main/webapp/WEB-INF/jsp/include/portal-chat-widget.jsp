<%@ page trimDirectiveWhitespaces="true" pageEncoding="UTF-8" %>
<%-- Floating help chat: POST ${initParam.nodeApiBase}/api/chat. Styles: /css/portal-chat-widget.css --%>
<div id="hm-portal-chat" aria-live="polite">

  <button type="button"
          class="portal-chat-fab"
          id="portal-chat-fab"
          aria-expanded="false"
          aria-controls="portal-chat-panel"
          title="Hospital help chat">
    <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
      <path d="M20 2H4C2.897 2 2 2.897 2 4v13c0 1.103.897 2 2 2h3v3.586L11.707 19H20
               c1.103 0 2-.897 2-2V4c0-1.103-.897-2-2-2zm-6 11H7v-2h7v2zm3-4H7V7h10v2z"/>
    </svg>
  </button>

  <div id="portal-chat-panel"
       class="portal-chat-panel"
       role="dialog"
       aria-modal="true"
       aria-labelledby="portal-chat-title"
       hidden>

    <div class="portal-chat-head">
      <div class="portal-chat-head-logo" aria-hidden="true">HM</div>
      <div class="portal-chat-head-text">
        <h2 class="portal-chat-title" id="portal-chat-title">Hospital Help</h2>
        <div class="portal-chat-online">Online - demo assistant</div>
      </div>
      <button type="button"
              class="portal-chat-close"
              id="portal-chat-close"
              aria-label="Close chat">
        <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
          <path d="M18 6L6 18M6 6l12 12"/>
        </svg>
      </button>
    </div>

    <div class="portal-chat-log"
         id="portal-chat-log"
         role="log"
         aria-label="Chat messages"></div>

    <div class="portal-chat-foot">
      <form class="portal-chat-form" id="portal-chat-form" autocomplete="off" novalidate>
        <label class="hm-pc-sr-only" for="portal-chat-input">Type your message</label>
        <input class="portal-chat-input"
               type="text"
               id="portal-chat-input"
               name="message"
               maxlength="2000"
               placeholder="Ask about hours, booking..."
               autocomplete="off"/>
        <button type="submit"
                class="portal-chat-send"
                id="portal-chat-send"
                aria-label="Send message">
          <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
            <path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z"/>
          </svg>
        </button>
      </form>
      <p class="portal-chat-hint">Demo assistant - not for personal health data or emergencies.</p>
    </div>

  </div>
</div>

<script>
(function () {
  'use strict';

  var API_BASE = '${initParam.nodeApiBase}';
  var CHAT_URL = API_BASE.replace(/\/$/, '') + '/api/chat';

  var fab = document.getElementById('portal-chat-fab');
  var panel = document.getElementById('portal-chat-panel');
  var closeBtn = document.getElementById('portal-chat-close');
  var logEl = document.getElementById('portal-chat-log');
  var form = document.getElementById('portal-chat-form');
  var input = document.getElementById('portal-chat-input');
  var sendBtn = document.getElementById('portal-chat-send');

  if (!fab || !panel || !logEl || !form || !input) return;

  function appendMsg(text, cls) {
    var div = document.createElement('div');
    div.className = 'portal-chat-msg ' + cls;
    div.textContent = text;
    logEl.appendChild(div);
    logEl.scrollTop = logEl.scrollHeight;
    return div;
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
          'Hi - ask about hours, booking appointments, or who to contact.',
          'bot'
        );
      }
    }
  }

  fab.addEventListener('click', function () { setOpen(panel.hidden); });
  if (closeBtn) {
    closeBtn.addEventListener('click', function () { setOpen(false); fab.focus(); });
  }

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
        typeof data.reply === 'string'
          ? data.reply
          : 'Unexpected response from help service.',
        typeof data.reply === 'string' ? 'bot' : 'err'
      );
    } catch (err) {
      removeTyping();
      appendMsg('Could not reach the help service. Is the Node API running on port 3001?', 'err');
    } finally {
      sendBtn.disabled = false;
      input.focus();
    }
  });
})();
</script>
