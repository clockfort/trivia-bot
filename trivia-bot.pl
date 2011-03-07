#!/usr/bin/perl
use strict;
use warnings;
use REST::Google::Search;
use List::Util qw[min max];
use XML::Simple;
use Data::Dumper; #For debugging XML
use Time::HiRes qw (time);

REST::Google::Search->http_referer('http://google.com');
my @questions;
import_questions_from_xml("questions/sample_questions.xml");


my $num_correct=0;
my %scores;
foreach my $question_node_ref (@questions){
	my $start_time = [Time::HiRes::gettimeofday];
	my %question_node = %$question_node_ref;

	my $question = $question_node{'question'};
	my $answer = $question_node{'answer'};
	my $answer_pool_ref = $question_node{'answer_pool'};
	my @answer_pool = @$answer_pool_ref;
	
	my $scores_ref = find_best($question, \@answer_pool);

	print "Question: $question\n";
	%scores = %$scores_ref;
	my @keys;
	foreach my $key (sort score_hash_cmp (keys(%scores))){
		my $p = $scores{$key};
		$p = sprintf("%.4f", $p);
		print "Answer: $key P=$p\n";
		push (@keys,$key);
	}
	my $final_answer = (sort score_hash_cmp (keys(%scores)))[0];
	my $elapsed_time = Time::HiRes::tv_interval($start_time);
	if( $final_answer eq $answer){
		print "CORRECT!\n";
		++$num_correct;
	}
	else{
		print "WRONG.\n";
	}
	print "Elapsed time: $elapsed_time seconds.\n\n";
}

my $number_of_questions = scalar(@questions);
print "We got $num_correct of $number_of_questions questions correct.\n";


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

sub score_hash_cmp{
	$scores{$b} <=> $scores{$a};
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


sub num_results_for_query{
	my $query = shift;

        my $res = REST::Google::Search->new(
       	        q => $query,
        );

       	die "response status failure" if $res->responseStatus != 200;
        my $data = $res->responseData;

       	my $cursor = $data->cursor;
        return $cursor->estimatedResultCount;
}


sub find_best{
	my $question = shift;
	my $options_ref = shift;
	my @options = @$options_ref;

	my %results = ();

	my ($best_result,$max_results)=("",0);
	foreach my $possible_answer (@options){
		my @query_permutations = permutate($question);
		foreach my $base_query (@query_permutations){
			my $num_results = num_results_for_query($base_query.' '."\"".$possible_answer."\"");
			my $score = $num_results; #TODO make score more complicated

			if(exists($results{$possible_answer})){
				my $ref = $results{$possible_answer};
				my @res = @$ref;
				push(@res, $score);
				$results{$possible_answer} = \@res;
			}
			else{
				$results{$possible_answer} = [$score];
				
			}
		}
	}
	
	my %scored_results = ();
	my $sum_score = 0;

	foreach my $possible_answer (keys(%results)){
		my $scores_ref = $results{$possible_answer};
		my @scores = @$scores_ref;
		my $score = eval join '+', @scores; #sum
		$sum_score += $score;
		$scored_results{$possible_answer} = $score;
	}
	
	#Normalize
	my @scores;
	foreach my $possible_answer (keys(%scored_results)){
		$scored_results{$possible_answer} /= $sum_score;
	}

	return \%scored_results;
}

#TODO add query permutations that will be helpful
sub permutate{
my $question = shift;
}
