#!/usr/bin/perl
use strict;
use warnings;
use REST::Google::Search;
REST::Google::Search->http_referer('http://google.com');
my @questions;

push(@questions,gen_question_node("The Louisiana Purchase involved land bought by the U.S. from:","france",["canada","england","mexico","france"]));
push(@questions,gen_question_node("At Altamont in 1969, a vicious fight broke out during a performance of:","Sympathy for the Devil",["The Candyman", "Born to be Wild", "Sympathy for the Devil", "All Along the Watchtower"]));
push(@questions,gen_question_node("Which cat movie is animated?","gay purr-ee",["Three lives of thomasina", "cat people", "gay purr-ee", "The Black Cat"]));
push(@questions,gen_question_node("What's the main ingredient in a serving of huevos rancheros?","Eggs",["Soup", "Eggs", "Nuts", "Chicken"]));
push(@questions,gen_question_node("Busby Berkeley gained fame in the 1920's and 1930's as a:","Choreographer",["Pro baseball player","Bank Robber","Choreographer","Band Leader"]));
push(@questions,gen_question_node("Its largest airport is named for a World War II hero, its second largest for a World War II battle.", "Chicago", ["Chicago", "Toronto", "New York", "Opelika"]));
push(@questions,gen_question_node("What historical event took place on June 18, 1815?", "Battle of Waterloo", ["Steam Engine Patented", "Antarctica Discovered", "Battle of Waterloo", "Mexicans take the Alamo"]));
push(@questions,gen_question_node("Which explorer is famous for his three voyages to the pacific?", "James Cook", ["James Cook", "Abel Tasman", "Alexander Mackenzie", "Vitus Bering"]));
push(@questions,gen_question_node("Istanbul is the only city in the world that is:", "Situated on 2 Continents", ["Only reached by air", "Universally Neutral", "Situated on 2 Continents", "3/4 Underwater"]));
push(@questions,gen_question_node("Which great man of history was orphaned at an early age?","Confucius",["Confucius","William the Conqueror","Martin Luther King Jr.","Alexander the Great"]));
push(@questions,gen_question_node("Myasthenia gravis is one of the most common _____ diseases.","Neuromuscular",["Digestive","Neuromuscular","Lung","Airborne"]));
push(@questions,gen_question_node("This Pepsi drink was introduced in 1948 and competes with Mello Yello.", "Mountain Dew", ["Coke","Pepsi","Mountain Dew","Sierra Mist"]));

my $num_correct=0;
foreach my $question_node_ref (@questions){
	my %question_node = %$question_node_ref;

	my $question = $question_node{'question'};
	my $answer = $question_node{'answer'};
	my $answer_pool_ref = $question_node{'answer_pool'};
	my @answer_pool = @$answer_pool_ref;

	my $final_answer = find_best($question, \@answer_pool);
	print "Question: $question \nAnswer: $final_answer.\n";
	if($final_answer eq $answer){
		print "CORRECT!\n\n";
		++$num_correct;
	}
	else{
		print "WRONG.\n\n";
	}
}

my $number_of_questions = scalar(@questions);
print "We got $num_correct of $number_of_questions questions correct.\n";

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

	my $base_query = $question;

	my ($best_result,$max_results)=("",0);
	foreach my $possible_answer (@options){
		my $num_results = num_results_for_query($base_query.' '."\"".$possible_answer."\"");
	        if($num_results>$max_results){
	                ($best_result,$max_results) = ($possible_answer, $num_results);
        	} 
	}
	return $best_result;
}
