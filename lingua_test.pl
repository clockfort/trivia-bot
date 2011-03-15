#!/usr/bin/perl
use Lingua::LinkParser;
use strict;

my $parser = new Lingua::LinkParser;        # create the parser
my $text   = "Moses supposes his toses are roses.";

  my $sentence = $parser->create_sentence($text); # parse the sentence
  my $linkage  = $sentence->linkage(1);        # use the first linkage
  
  print $parser->get_diagram($linkage);         # print it out
