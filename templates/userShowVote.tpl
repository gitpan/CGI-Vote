[% PROCESS userHeader.tpl
	title = "參加投票"
	functionTitle = "做啥？" %]

[% IF VOTE_EXPIRED%]
<h1>此投票已經結束</h1>

<div id='voteInfoBlock' class='blockLeftRight' >

 <div class='blockRow'>
  <h3 class='blockOneColumn'>[% vote.title %]</h3>
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


[% ELSIF MSG_VOTE_SUCCESS %]
<h1>您投的這一票已經列入統計</h1>
[% ELSIF MSG_VOTE_NOT_COUNTED_USER_FLOOD %]
<h1>您投的這一票未列入統計</h1>

<p class="warning">
本投票系統禁止同一 IP 位址的連續投票行為，
同一 IP 位址在一個小時之內只能投一票。
</p>
[% ELSIF vote %]
<form action="vote.pl">
<input type="hidden" name="op" value="makeVote" />
<input type="hidden" name="voteId" value="[% vote.id %]" />

<div id='voteInfoBlock' class='blockLeftRight' >

 <div class='blockRow'>
  <h3 class='blockOneColumn'>[% vote.title %]</h3>
 </div>

 <div class='blockRow'>
  <p class='blockOneColumn'>[% vote.description %]</p>
 </div>


 <div class='blockRow'>
  <div class='blockLeftColumn'>
    開票日：
  </div>

  <div class='blockRightColumn'>
    [% vote.expireDate %]
  </div>
 </div>

 <div class='blockRow'>
  <div class='blockOneColumn'>
    [% IF vote.multiple > 1 %]
    可複選 [% vote.multiple %] 項
    [% ELSE %]
    單選
    [% END %]
    [% IF MSG_CHOICE_OVERFLOW %]
    ，<font color="red">您選太多了，請少選幾項</font>
    [% ELSIF MSG_CHOICE_UNDERFLOW %]
    ，<font color="red">您選太少了，請多選幾項</font>
    [% END %]
  </div>
 </div>

[% SET i = 0 %]
[% FOREACH o = vote.options %]
 <div class='blockRow'>
  <div class='blockLeftColumn'>
	<input type='checkbox' name='optionsTaken' value='[% i %]'
         [% isChecked(i) %]/>[% i+1 %].
  </div>

  <div class='blockRightColumn'>
	[% o %]
  </div>
 </div>
[% SET i = i+1 %]
[% END %]

 <div class='blockRow'>
  <div class='blockOneColumn'>
	<input type='submit' name='MakeVote'   value="投下這一票"/>
	<input type='submit' name='CancelVote' value="不想投了"/>
  </div>
 </div>


</div>
</form>
[% END %]

[% PROCESS userFooter.tpl %]
