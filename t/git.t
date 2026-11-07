use strict;
use warnings;

use Carp::Always;
use Open::This qw( maybe_get_url_from_parsed_text );
use Path::Tiny qw(path tempdir);
use Test::More import => [qw( done_testing is like ok skip )];
use Test::Needs qw( Git::Helpers );
use Test::Requires::Git;
use URI ();

test_requires_git();

SKIP: {
    skip 'must be inside Git checkout', 1
        unless Git::Helpers::is_inside_work_tree();

    local $ENV{OPEN_THIS_REMOTES} = q{};

    is( maybe_get_url_from_parsed_text(),     undef, 'undef on undef' );
    is( maybe_get_url_from_parsed_text( {} ), undef, 'undef on empty hash' );

    my $url = maybe_get_url_from_parsed_text(
        { file_name => 'lib/Open/This.pm' } );
    ok( $url, 'got url' );
    my $uri = URI->new($url);
    ok( $uri->path =~ m{lib/Open/This.pm\z}, 'path' );
    is( $uri->scheme, 'https', 'scheme' );

    $url = maybe_get_url_from_parsed_text(
        { file_name => 'lib/Open/This.pm' } );
    ok( $url, 'got url' );
    $uri = URI->new($url);
    ok( $uri->path =~ m{lib/Open/This.pm\z}, 'path' );
    is( $uri->scheme, 'https', 'scheme' );

    $url = maybe_get_url_from_parsed_text(
        { file_name => 'lib/Open/This.pm' } );
    ok( $url, 'got url' );
    $uri = URI->new($url);
    ok( $uri->path =~ m{lib/Open/This.pm\z}, 'path' );
    is( $uri->scheme, 'https', 'scheme' );

    my $cwd  = path('.')->absolute;
    my $repo = tempdir();
    chdir $repo or die "chdir $repo: $!";
    for my $cmd (
        [qw( git init -q )],
        [
            qw( git -c user.name=t -c user.email=t@example.com commit -q --allow-empty -m init )
        ],
        [qw( git remote add origin https://github.com/Orig/repo.git )],
        [qw( git remote add upstream git@github.com:Up/repo.git )],
    ) {
        system(@$cmd) == 0 or die "@$cmd failed";
    }

    for my $case (
        [ q{},               qr{^/Orig/repo/blob/} ],
        [ 'nope',            qr{^/Orig/repo/blob/} ],
        [ 'upstream',        qr{^/Up/repo/blob/} ],
        [ 'nope,upstream',   qr{^/Up/repo/blob/} ],
        [ 'origin,upstream', qr{^/Orig/repo/blob/} ],
    ) {
        my ( $remotes, $expected ) = @$case;
        local $ENV{OPEN_THIS_REMOTES} = $remotes;
        my $current_url = maybe_get_url_from_parsed_text(
            { file_name => 'lib/Open/This.pm' } );
        like(
            URI->new($current_url)->path, $expected,
            "OPEN_THIS_REMOTES='$remotes'"
        );
    }

    chdir $cwd or die "chdir $cwd: $!";
}

done_testing();
