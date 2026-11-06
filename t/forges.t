use strict;
use warnings;

use Open::This qw( maybe_get_url_from_parsed_text );
use Test::More import => [qw( done_testing is )];
use Test::Needs    qw( Git::Helpers );
use Test::Warnings ();
use URI            ();

no warnings 'redefine';
local *Git::Helpers::current_branch_name = sub { 'main' };

my $file  = 'lib/Open/This.pm';
my @cases = (
    [
        'https://github.com/o/r', "https://github.com/o/r/blob/main/$file#L32"
    ],
    [
        'https://gitlab.com/g/sub/r',
        "https://gitlab.com/g/sub/r/-/blob/main/$file#L32"
    ],
    [
        'https://codeberg.org/o/r',
        "https://codeberg.org/o/r/src/branch/main/$file#L32"
    ],
    [
        'https://bitbucket.org/o/r',
        "https://bitbucket.org/o/r/src/main/$file#lines-32"
    ],
    [
        'https://git.sr.ht/~o/r',
        "https://git.sr.ht/~o/r/tree/main/item/$file#L32"
    ],
    [
        'https://git.example.com/o/r',
        "https://git.example.com/o/r/blob/main/$file#L32"
    ],
);

for my $case (@cases) {
    my ( $remote, $expected ) = @$case;
    local *Git::Helpers::https_remote_url = sub { URI->new($remote) };
    is(
        maybe_get_url_from_parsed_text(
            { file_name => $file, line_number => 32 }
        ),
        $expected,
        "browse URL for $remote"
    );
}

done_testing();
