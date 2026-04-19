<%@ page trimDirectiveWhitespaces="true" %>
<%-- Fixes CSS 404s on nested paths (/patient/dashboard, /doctor/dashboard): resources always resolve from webapp root. --%>
<%
  String ctx = request.getContextPath();
  String baseHref = ctx == null || ctx.isEmpty() ? "/" : ctx + "/";
%>
<base href="<%= baseHref %>"/>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
      integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500;600&family=Playfair+Display:wght@600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="css/app.css"/>
<link rel="stylesheet" href="css/portal.css"/>
<%-- Root-absolute href so the chat CSS always resolves (not dependent on &lt;base&gt; quirks). --%>
<link rel="stylesheet" href="<%= ctx %>/css/portal-chat-widget.css"/>
