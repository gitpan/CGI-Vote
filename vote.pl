#!/usr/local/bin/perl

use strict;
use Apache;
use Template;
use CGI::Lite;
use CGI::Vote;
use Date::Format;
use Date::Parse;
use DB_File;
use YAML;

use constant ALLOWED  => 0;
use constant FUNCTION => 1;

my $remote_ip = Apache->request->get_remote_host;

my $template = Template->new
  ({
    INCLUDE_PATH => CGI_VOTE_PATH . '/templates',
    POST_CHOMP   => 1,               # cleanup whitespace
   });

my $FUNCTIONS = 
    [
     [ 'List Votes'     , 'vote.pl'   ],
#     [ 'Old Votes'      , 'vote.pl?op=showOldVotes'  ],
    ];

my $cgi  = new CGI::Lite;
my $form = $cgi->parse_form_data;

my %ops = (
	   listOldVotes => [ 1, \&listOldVotes ] ,
	   showVote	=> [ 1,	\&showVote   ] ,
	   makeVote	=> [ 1,	\&makeVote   ] ,
	   default	=> [ 1,	\&showMain ] ,
	   );

# {$ops->{$op}}($form,$template);
my $op = $form->{'op'};
if (!$op || !exists $ops{$op} || !$ops{$op}[ALLOWED]) {
    $op = 'default';
}

$ops{$op}[FUNCTION]->($form,$template);

sub showMain {
    my ($form,$tt) = @_;

    my $vars = {
	functions => $FUNCTIONS,
	votes => scalar(getVoteList('vote.pl','showVote')),
	now   => time(),
	remote_ip => $remote_ip,
    };
    $tt->process('userMain.tpl',$vars) || die $tt->error() . "\n";
}

sub showVote {
    my ($form,$tt) = @_;
    my $vars = {
	functions => $FUNCTIONS,
	form  => $form,
	now   => time(),
    };

    if($form->{id}) {
	$vars->{vote} = getVoteInfo($form->{id});
	if(time() - str2time($vars->{vote}->{expireDate}) > 0) {
	    $vars->{VOTE_EXPIRED} = 1;
	    my $vs  = $vars->{vote};
	    my $n   = scalar(@{$vs->{options}});
	    my $vo  = $vs->{options};
	    my $vst = $vs->{statics};
	    my @voo = map {[ $vo->[$_], $vst->[$_] || 0 ]} (0..$n-1);
	    $vars->{voteStatics} = \@voo;
	}
    }

     $tt->process('userShowVote.tpl',$vars)
      || die $tt->error() . "\n";
}

sub listOldVotes {
    my ($form,$tt) = @_;
}

sub makeVote {
    my ($form,$tt) = @_;

    if($form->{CancelVote}) {
	showMain(undef,$tt);
	return;
    }

    my $vars = {
	functions => $FUNCTIONS,
	form  => $form,
	isChecked => sub {
	    my $p = shift;
	    if(ref($form->{optionsTaken}) eq 'ARRAY' ) {
		foreach(@{$form->{optionsTaken}}) {
		    return "checked" if("$_" eq "$p");
		}
	    } else {
		return "checked" if("$form->{optionsTaken}" eq "$p");
	    }
	    return "";
	},
    };

    my $v=getVoteInfo($form->{voteId});
    $vars->{vote} = $v;
    my $n=0;
    if(ref($form->{optionsTaken}) eq 'ARRAY') {
	$n = scalar @{$form->{optionsTaken}};
    } else {
	$n = (length($form->{optionsTaken})>0)?1:0;
    }
    $v->{multiple} ||= 1;
    if($n > $v->{multiple}) {
	$vars->{MSG_CHOICE_OVERFLOW} = 1;
    }elsif($n == 0 ) {
	$vars->{MSG_CHOICE_UNDERFLOW} = 1;
    }else {
	my $userId = $remote_ip;
	my $r = storeVoteTicket($form->{voteId},$userId,$form->{optionsTaken});
	if($r == 1) {
	    $vars->{MSG_VOTE_SUCCESS} = 1;
	} elsif ($r == -1) {
	    $vars->{MSG_VOTE_NOT_COUNTED_USER_FLOOD} = 1;
	}
    }
    $tt->process('userShowVote.tpl',$vars)
	|| die $tt->error() . "\n";
}

