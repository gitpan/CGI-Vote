[% PROCESS adminHeader.tpl
	title = "建立投票"
	functionTitle = "到底要做啥？" %]

[% IF NEW_VOTE_CREATED %]
<h3>新的投票已經建立，識別碼 [% new_vote_id %]</h3>
[% ELSE %]

<form action='admin.pl'>
  <input type='hidden' name='op' value='createVotes' />

  <div id='newVoteFormBlock' class='blockLeftRight'>

  <div class='blockRow'>
    <div class='blockLeftColumn'>投票的名字：</div>
    <div class='blockRightColumn'>
      <input type='text' name='newVoteName' value="[% form.newVoteName %]" /></div>
  </div>

  <div class='blockRow'>
  <div class='blockLeftColumn'>關於此投票的文字描述：</div>
  <div class='blockRightColumn'>
    <textarea name='newVoteDescription' >[% form.newVoteDescription %]</textarea></div>
  </div>

  <div class='blockRow'>
    <div class='blockLeftColumn'>開票日：(ex: 2003/09/21)</div>
    <div class='blockRightColumn'>
      <input type='text' name='newVoteExpireDate' value="[% form.newVoteExpireDate %]" /></div>
  </div>

  <div class='blockRow'>
    <div class='blockLeftColumn'>複選數目（單選請填 1）</div>
    <div class='blockRightColumn'>
      <input type='text' name='newVoteMultiple' value="[% form.newVoteMultiple || 1 %]" /></div>
  </div>

  <div class='blockRow'>
    <div class='blockLeftColumn'>選項：</div>
  </div>

  [% SET i = 0 %]
  [% UNLESS form.nOptions > 0 %] [% SET form.nOptions = 5 %] [% END %]
  <input type='hidden' name='nOptions' value="[% form.nOptions %]" />
  [% FOREACH o = form.newVoteOptions %]
    <div class='blockRow'>
	<div class='blockLeftColumn'>[% i+1 %]：</div>
	<div class='blockRightColumn'>
	  <input type='text' name='newVoteOptions'
	     value='[% o %]' /></div>
    </div>
    [% i = i+1 %]
  [% END %]
  [% WHILE i < form.nOptions %]
    <div class='blockRow'>
	<div class='blockLeftColumn'>[% i+1 %]：</div>
	<div class='blockRightColumn'>
	  <input type='text' name='newVoteOptions' /></div>
    </div>
    [% i = i+1 %]
  [% END %]

  <div class='blockRow'>
   <div class='blockOneColumn'>
    <input type='submit' name='voteOneMoreOptions' value='再一個選項' />
    <input type='submit' name='voteFiveMoreOptions' value='再五個選項' />
    <input type='submit' name='voteTenMoreOptions' value='再十個選項' />
    <input type='submit' name='voteCommit' value='確定建立' />
    <input type='submit' name='voteCancel' value='取消建立' />
   </div>
  </div>

  </div> <!-- end of newVoteFormBlock -->

</form>
[% END %]

[% IF debug %] <hr/><pre>[% debug %]</pre> [% END %]

[% PROCESS adminFooter.tpl %]
