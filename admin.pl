#!/usr/local/bin/perl

use strict;
use CGI::Lite;
use CGI::Vote;
use Date::Parse;
use DB_File;
use Template;
use YAML;

use constant ALLOWED  => 0;
use constant FUNCTION => 1;

my $FUNCTIONS = 
    [
     [ 'List Votes'       , 'admin.pl?op=listVotes'   ],
     [ 'Watch Votes'      , 'admin.pl?op=watchVotes'  ],
     [ 'Delete Votes'     , 'admin.pl?op=delVotes'    ],
     [ 'Create New Votes' , 'admin.pl?op=createVotes' ]
     ];

my $template = Template->new
  ({
    INCLUDE_PATH => CGI_VOTE_PATH . "/templates",
    POST_CHOMP   => 1,               # cleanup whitespace
   });

my $cgi  = new CGI::Lite;
my $form = $cgi->parse_form_data;

my %ops = (
	   listVotes	=> [ 1,	\&listVotes   ] ,
	   watchVotes	=> [ 1,	\&watchVotes  ] ,
	   delVotes	=> [ 1,	\&delVotes    ] ,
	   createVotes	=> [ 1,	\&createVotes ] ,
	   default	=> [ 1,	\&listVotes ] ,
	   );

# {$ops->{$op}}($form,$template);
my $op = $form->{'op'};
if (!$op || !exists $ops{$op} || !$ops{$op}[ALLOWED]) {
    $op = 'default';
}

$ops{$op}[FUNCTION]->($form,$template);

sub listVotes {
    my ($form,$tt) = @_;
    my $vars = {
	functions => $FUNCTIONS,
	votes     => scalar(getVoteList("admin.pl","watchVotes")),
	now       => time(),
    };

    $tt->process('adminListVotes.tpl',$vars)
	|| die $tt->error() . "\n";
}

sub watchVotes {
    my ($form,$tt) = @_;
    my $vars = {
	functions => $FUNCTIONS,
	votes     => scalar(getVoteList('admin.pl','watchVotes')),
	form      => $form,
	now       => time(),
    };

    if($form->{id}) {
	$vars->{vote} = getVoteInfo($form->{id});
	my $vs  = $vars->{vote};
	my $n   = scalar(@{$vs->{options}});
	my $vo  = $vs->{options};
	my $vst = $vs->{statics};
	my @voo = map {[ $vo->[$_], $vst->[$_] || 0 ]} (0..$n-1);
	$vars->{voteStatics} = \@voo;
    }

    $tt->process('adminWatchVotes.tpl',$vars)
	|| die $tt->error() . "\n";
}

sub delVotes {
    my ($form,$tt) = @_;
    my $vars = {
	functions => $FUNCTIONS,
	form      => $form,
	now       => time(),
    };
    my $id = $form->{id} || 0;
    unless($id == 0) {
	$vars->{VOTE_DELETED} = 1;
	deleteVote($id);

    }
    $vars->{votes} = scalar(getVoteList('admin.pl',"delVotes")),
    $tt->process('adminDelVotes.tpl',$vars)
	|| die $tt->error() . "\n";
}

sub createVotes {
    my ($form,$tt) = @_;

    my $vars = {
	functions => $FUNCTIONS ,
	form      => $form ,
    };

    if($form->{'voteOneMoreOptions'}) {
	$vars->{form}->{nOptions} += 1;
    } elsif($form->{'voteFiveMoreOptions'}) {
	$vars->{form}->{nOptions} += 5;
    } elsif ($form->{'voteTenMoreOptions'}) {
	$vars->{form}->{nOptions} += 10;
    } elsif ($form->{'voteCommit'}) {
	my $id = createNewVote($form->{newVoteName},
			       $form->{newVoteDescription},
			       $form->{newVoteExpireDate},
			       $form->{newVoteMultiple},
			       trimList($form->{newVoteOptions}));
	$vars->{NEW_VOTE_CREATED} = 1;
	$vars->{new_vote_id} = $id;
    }

    $tt->process('adminCreateVotes.tpl',$vars)
	|| die $tt->error() . "\n";
}
