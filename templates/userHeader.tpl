<html>

<head>
<title>[% title %]</title>
<link rel="stylesheet" href="user.css" type="text/css" />
</head>
<body>

<div class="topBlock">
  <h1 id='title'>[% title %]</h1>
</div>

<div class="UltraContainer">

[% IF functions %]
<div class="menu">
[% PROCESS functionBlock.tpl %]
</div>
[% END %]

<div class="content">

