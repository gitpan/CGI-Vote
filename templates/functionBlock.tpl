<div id='functionBlock'>
  <div id='functionTitle'>[% functionTitle %]</div>
  <ul  id='functions'>
  [% FOREACH f = functions %]
    <li><a href="[% f.1 %]">[% PROCESS Translate.tpl msg = f.0 %]</a></li>
  [% END %]
  </ul>
</div>
