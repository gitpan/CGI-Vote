package CGI::Vote;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(getVoteList getVoteInfo storeVoteTicket createNewVote deleteVote max trimList CGI_VOTE_PATH);
@EXPORT_OK = qw(getVoteList getVoteInfo storeVoteTicket max trimList CGI_VOTE_PATH);

use vars qw($VERSION);

$VERSION = '0.10';

use strict;
use DB_File;
use Date::Format;
use Date::Parse;
use YAML;

use constant CGI_VOTE_PATH => $ENV{'CGI_VOTE_PATH'} || '/usr/local/www/cgi-vote';

sub getVoteList {
    my ($action,$op) = @_;
    my %votes;
    tie %votes, 'DB_File', CGI_VOTE_PATH ."/db/voteList.db",O_CREAT|O_RDWR;
    my @voteList =
	map  { my $v = Load($votes{$_});
	       [ $v->[0] , "${action}?op=${op}&id=${_}" ,
		 $v->[1] ] }
	sort { $b <=> $a } keys (%votes);

    untie %votes;
    return wantarray ? @voteList : \@voteList;
}

sub getVoteInfo {
    my $id = shift;
    my %v;
    tie %v, 'DB_File', CGI_VOTE_PATH ."/db/vote.${id}.db",O_CREAT|O_RDWR;
    return {
	id          => $id,
	title       => $v{title},
	description => $v{description},
	expireDate  => time2str("%Y/%m/%d",$v{expireDate}),
	options     => Load($v{options}),
	multiple    => $v{multiple},
	statics     => Load($v{statics}),
    };
}

sub storeVoteTicket {
    my ($id,$userId,$options) = @_;
    my %v;
    tie %v, 'DB_File', CGI_VOTE_PATH ."/db/vote.${id}.db",O_CREAT|O_RDWR;

    my %u;
    tie %u, 'DB_File', CGI_VOTE_PATH ."/db/vote.user.${id}.db",O_CREAT|O_RDWR;
    my $now = time;
    return -1 if($now - $u{$userId} < 3600);
    $u{$userId} = $now;

    my $statics = Load($v{'statics'});
    if(ref($options) eq 'ARRAY') {
	foreach (@{$options}) {
	    $statics->[$_] += 1;
	}
    }else {
	$statics->[$options] += 1;
    }
    $v{'statics'} = Dump($statics);
    untie %v;
    untie %u;

    return 1;
}

sub createNewVote {
    my ($title,$desc,$expireDate,$multiple,$options) = @_;
    my %votes;
    my %vote;
    tie %votes, 'DB_File', CGI_VOTE_PATH ."/db/voteList.db",O_CREAT|O_RDWR;

    my $id = max(keys %votes) + 1;
    my $dbf = CGI_VOTE_PATH . "/db/vote.${id}.db",O_CREAT|O_RDWR;

    $votes{$id} = Dump([$title,str2time($expireDate)]);

    tie %vote, 'DB_File', $dbf;
    $vote{title}       = $title;
    $vote{description} = $desc;
    $vote{expireDate}  = str2time($expireDate);
    $vote{multiple}    = $multiple;
    $vote{options}     = Dump($options); # $options is arrayref

    my $statics = [ ];
    foreach (@$options) { push @$statics, 0; }
    $vote{statics}     = Dump($statics);

    untie %votes; untie %vote;
    return $id;
}

sub deleteVote {
    my $id = shift;
    my %votes;
    tie %votes, 'DB_File', CGI_VOTE_PATH ."/db/voteList.db",O_CREAT|O_RDWR;
    delete $votes{$id};
    unlink(CGI_VOTE_PATH . "/db/vote.${id}.db");
    unlink(CGI_VOTE_PATH . "/db/vote.user.${id}.db");
    untie %votes;
    return 1;
}

sub max {
    my $m = shift;
    foreach my $n (@_) {
	$m = $n if($m < $n);
    }
    return $m || 0;
}

sub trimList {
    my $l = shift;
    foreach my $i (0 .. scalar(@$l)) {
	delete $l->[$i] if(length($l->[$i]) == 0)
    }
    return $l;
}

1;

__END__

=head1 NAME

CGI::Vote - A Template enhanced Vote CGI library.

=head1 SYNOPSIS

Just download the script+template tarball and use vote.pl and admin.pl.

=head1 DESCRIPTION

I found that there are very few free CGI that do with template, or
they goes like a giant monster (like Slash), so I decide to write
some, starting from this one.

=head1 CONFIGURATION

After you install the Vote.pm, please fetch the main cgi script and
templates from this url:

    http://gugod.org/cgi-vote-bundle.tar.gz

You may find the script and templates from the CPAN tarball too,
which is also useful.

Extract the tarball or copy the .pl,.css, templates/ and db/ files to
a stand-alone directory, such as /usr/local/www/cgi-vote/. And please
set environment variable CGI_VOTE_PATH to this path in your apache
http.conf.

    PerlSetupEnv On
    PerlSetEnv CGI_VOTE_PATH /usr/local/www/cgi-vote

Also remember to add ExecCGI options to that dir.

    <Directory /usr/local/www/cgi-vote>
        Options ExecCGI Includes Indexes FollowSymLinks
    </Directory>

Make sure you make the cgi-vote/db directory writable to the httpd
daemon.

=head1 TODO

Currently this CGI doesn't aware of session, which should be a
very important thing.

The other is that I'm wondering if I should add user authentication.

=head1 COPYRIGHT

Copyright 2003 by Kang-min Liu <gugod@gugod.org>.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See <http://www.perl.com/perl/misc/Artistic.html>

=cut
