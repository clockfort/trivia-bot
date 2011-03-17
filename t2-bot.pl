#!/usr/bin/perl
use strict;
use warnings;
use Time::HiRes qw (time);
use Trivia::Lingua;
use Trivia::Engine::Google::Simple;
use Trivia::Questions::Import;

my @questions=Trivia::Questions::Import::get_questions();

my $num_correct=0;
Trivia::Engine::Google::Simple::input(@questions);
Trivia::Engine::Google::Simple::solve();



