#!/usr/bin/perl

use 5.006;
use strict;
use warnings;

use Git::Wrapper;
use Path::Tiny;

print STDERR " ==> Create Git Test Repository\n";

my $repo_path = path('my_repo.git')->absolute;

mkdir $repo_path or die "Cannot create $repo_path";

{
    my $git = Git::Wrapper->new( $repo_path->stringify );
    $git->init;
    $git->config( 'user.email', 'test@example.com' );
    $git->config( 'user.name',  'Test' );

    my $file_A = $repo_path->child('A');
    my $file_B = $repo_path->child('B');
    $file_A->spew('5');
    $git->add('A');
    $git->commit( { message => 'initial commit' } );

    $file_A->spew('7');
    $git->add('A');
    $git->commit( { message => 'second commit' } );

    $git->branch('dev');
    $git->checkout('dev');

    $file_A->spew('11');
    $git->add('A');
    $file_B->spew('13');
    $git->add('B');
    $git->commit( { message => 'commit on dev branch' } );

    $git->checkout('master');

    $git->tag('my-tag');
}

print STDERR " ==> Clone\n";

my $ws = path('workspace');
$ws->mkpath;

print STDERR '  => Line: ', __LINE__, " \$git = Git::Wrapper->new\n";
my $git = Git::Wrapper->new( $ws->stringify );

print STDERR '  => Line: ', __LINE__, " \$git->clone\n";
$git->clone( $repo_path->stringify(), $ws->stringify );

exit 0 if @ARGV && $ARGV[0] eq '--setup-only';

print STDERR " ==> Checkout Tag\n";
print STDERR '  => Line: ', __LINE__, " \$git->checkout\n";
$git->checkout('my-tag');

print STDERR '  => Line: ', __LINE__, " checkout done\n";

# vim: ts=4 sts=4 sw=4 et: syntax=perl
