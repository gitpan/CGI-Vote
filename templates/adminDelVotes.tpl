[% PROCESS adminHeader.tpl
	title = "刪除投票"
	functionTitle = "啥？" %]

[% IF VOTE_DELETED %]
<h1>識別碼為[% form.id %]的投票已經成功的刪除了</h1>
[% END %]

[% IF votes.0 %]

<div id='voteListBlock'>
  <div id='delVoteTitle'>你要刪除那些投票？</div>
  <ul  id='votesLists'>
  [% FOREACH v = votes %]
    <li><a href="[% v.1 %]">[% v.0 %]</a></li>
  [% END %]
  </ul>
</div>

[% ELSE %]
<h1>現在沒有投票可以給你刪除</h1>
[% END %]

[% PROCESS adminFooter.tpl %]
