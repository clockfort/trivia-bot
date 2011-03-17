#!/usr/bin/perl
use strict;
use warnings;
use Time::HiRes qw (time);
use Trivia::Engine::Google::Simple;
use Trivia::Questions::Import;

my $running = 1;
while($running){
	print "\nEnter question: ";
	my $query = <>;
	my $rx_answers=1;
	my @answers;
	while($rx_answers){
		print "\nEnter possible answer (or blank to quit): ";
		my $possible_answer = <>;
		chomp ($possible_answer);
		if($possible_answer eq ""){
			$rx_answers=0;
		}
		else{
			push(@answers,$possible_answer);
		}
	}

	print "\nEnter actual answer: ";
	my $answer = <>;
	chomp ($answer);
	my $question = Trivia::Questions::Import::gen_question_node($query,$answer,\@answers);
	Trivia::Engine::Google::Simple::input($question);
	Trivia::Engine::Google::Simple::solve();
}


