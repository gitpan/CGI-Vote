use ExtUtils::MakeMaker;

WriteMakefile
  (
   AUTHOR              => 'Kang-min Liu (gugod@gugod.org)',
   ABSTRACT            => 'A simple, vote cgi. Designed with TT2.',
   DISTNAME            => 'CGI-Vote',
   NAME                => 'CGI::Vote',
   VERSION_FROM        => 'CGI/Vote.pm',
   PREREQ_PM           => {
       'CGI::Lite'     => '0',
       'YAML'          => '0',
       'DB_File'       => '0',
       'Date::Format'  => '0',
       'Date::Parse'   => '0',
       'Template'      => '0',
   },
   PM	=> {
	    'CGI/Vote.pm' => '$(INST_LIBDIR)/Vote.pm'
	   },
  );

