#!/usr/bin/perl
use strict;
use warnings;
use XML::Simple;
use Data::Dumper; #For debugging XML
require Trivia::Questions::Import;

sub import_test_from_file{
	Trivia::Questions::Import::import_questions_from_xml(shift);
}

sub import_test_questions{
	print "Importing test questions.\n";
	import_test_from_file("questions/sample_questions.xml");
	import_test_from_file("questions/bob.xml");
	import_test_from_file("questions/vickie_geometry.xml");
	import_test_from_file("questions/vickie_science.xml");
	import_test_from_file("questions/vickie_presidents.xml");
}

import_test_questions();

1;
