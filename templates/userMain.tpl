[% PROCESS userHeader.tpl
	title = "大家來投票"
	functionTitle = "做啥？" %]

[% IF votes.0 %]
<div id='voteListBlock'>
  <ul  id='votesLists'>
  [% FOREACH v = votes %]
    [% IF (now - v.2) < 0 %]
      <li><a href="[% v.1 %]">[% v.0 %]</a></li>
    [% ELSE %]
      <li><a href="[% v.1 %]">[% v.0 %]  (已結束)</a></li>
    [% END %]
  [% END %]
  </ul>
</div>
[% ELSE %]
<h1>尚無舉辦任何投票</h1>
[% END %]

[% PROCESS userFooter.tpl %]
