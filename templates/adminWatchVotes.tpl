[% PROCESS adminHeader.tpl
	title = "偷看投票"
	functionTitle = "做啥？" %]

[% IF vote %]
<div id='voteInfoBlock' class='blockLeftRight' >

 <div class='blockRow'>
  <h3 class='blockOneColumn'>[% vote.title %]([% vote.id %])</h3>
 </div>

 <div class='blockRow'>
  <p class='blockOneColumn'>[% vote.description %]</p>
 </div>


 <div class='blockRow'>
  <div class='blockLeftColumn'>
    到期日：
  </div>

  <div class='blockRightColumn'>
    [% vote.expireDate %]
  </div>
 </div>

 [% FOREACH v = voteStatics %]
 <div class='blockRow'>
  <div class='blockLeftColumn'>
   [% v.0 %]：
  </div>

  <div class='blockRightColumn'>
   [% v.1 %]
  </div>
 </div>
 [% END %]

</div>
[% ELSIF votes.0 %]
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

[% PROCESS adminFooter.tpl %]

