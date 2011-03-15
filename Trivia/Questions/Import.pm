#!/usr/bin/perl
use strict;
use warnings;
package Trivia::Questions::Import;
use XML::Simple;
use Data::Dumper;

import_test_questions();
my @questions;

sub import_questions_from_xml{
	my $filename = shift;
	my $question_xml = XMLin($filename);
	$question_xml = $question_xml->{'question'};
	foreach my $question (@$question_xml){
		my $query = $question->{'query'};
		my $answer = $question->{'answer'};
		my $choice_ref = $question->{'choice'};
		my @choices = @$choice_ref;
		push(@choices,$answer);
		@choices = sort(@choices); #Wouldn't want the answer to always be in one place
		push(@questions,gen_question_node($query, $answer, \@choices));
	}
}

sub import_test_from_file{
	Trivia::Questions::Import::import_questions_from_xml(shift);
}

sub import_test_questions{
	print "Importing test questions.\n";
	import_questions_from_xml("questions/sample_questions.xml");
	import_questions_from_xml("questions/bob.xml");
	import_questions_from_xml("questions/vickie_geometry.xml");
	import_questions_from_xml("questions/vickie_science.xml");
	import_questions_from_xml("questions/vickie_presidents.xml");
	my $num_questions = scalar(@questions);
	print "Num_questions: $num_questions\n";
}

sub get_questions{
	return @questions;
}

sub gen_question_node{
	my $q = shift;
	my $a = shift;
	my $p_ref = shift;

	my %question_node = ();
	$question_node{'question'} = $q;
	$question_node{'answer'} = $a;
	$question_node{'answer_pool'} = $p_ref;

	
	return \%question_node;
}

1;
