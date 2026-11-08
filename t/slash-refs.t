use strict;
use warnings;

use Open::This        qw( to_editor_args );
use Path::Tiny        qw( path tempdir );
use Test::Differences qw( eq_or_diff );
use Test::More import => [qw( done_testing )];
use Test::Requires::Git;
use Test::Warnings ();

test_requires_git();

local $ENV{EDITOR} = 'vim';

# A pasted URL can't say where a ref like "feature/x" ends, so git decides
my $repo = tempdir();
$repo->child('lib')->mkpath;
$repo->child('lib/Foo.pm')->spew('1;');

my $cwd = path('.')->absolute;
chdir $repo or die "chdir $repo: $!";
for my $cmd (
    [qw( init -q )],
    [qw( -c user.name=t -c user.email=t@t commit -q --allow-empty -m init )],
    [qw( branch feature/x )],
) {
    system( 'git', @$cmd ) == 0 or die "git @$cmd failed";
}

my @cases = (
    [
        'https://github.com/o/r/blob/feature/x/lib/Foo.pm#L5',
        [ '+5', 'lib/Foo.pm' ],
        'GitHub ref with a slash'
    ],
    [
        'https://gitlab.com/g/r/-/blob/feature/x/lib/Foo.pm#L5',
        [ '+5', 'lib/Foo.pm' ],
        'GitLab ref with a slash'
    ],
    [
        'https://codeberg.org/o/r/src/branch/feature/x/lib/Foo.pm#L5',
        [ '+5', 'lib/Foo.pm' ],
        'Codeberg ref with a slash'
    ],
    [
        'https://bitbucket.org/o/r/src/feature/x/lib/Foo.pm#lines-5',
        [ '+5', 'lib/Foo.pm' ],
        'Bitbucket ref with a slash'
    ],
    [
        'https://git.sr.ht/~o/r/tree/feature/x/item/lib/Foo.pm#L5',
        [ '+5', 'lib/Foo.pm' ],
        'SourceHut ref with a slash'
    ],
    [
        'https://github.com/o/r/blob/nope/x/lib/Foo.pm',
        [],
        'unknown ref does not shorten the path to another file'
    ],
);

for my $case (@cases) {
    my ( $url, $expected, $name ) = @$case;
    eq_or_diff( [ to_editor_args($url) ], $expected, $name );
}

chdir $cwd or die "chdir $cwd: $!";

done_testing();
