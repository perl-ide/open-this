use strict;
use warnings;

use Open::This qw( maybe_get_url_from_parsed_text );
use Test::More import => [qw( done_testing is )];
use Test::Needs    qw( Git::Helpers );
use Test::Warnings ();
use URI            ();

no warnings 'redefine';
local *Git::Helpers::current_branch_name = sub { 'topic' };

my $file  = 'lib/Open/This.pm';
my @cases = (
    [
        'https://github.com/o/r',
        "https://github.com/o/r/blob/topic/$file#L32"
    ],
    [
        'https://gitlab.com/g/sub/r',
        "https://gitlab.com/g/sub/r/-/blob/topic/$file#L32"
    ],
    [
        'https://codeberg.org/o/r',
        "https://codeberg.org/o/r/src/branch/topic/$file#L32"
    ],
    [
        'https://bitbucket.org/o/r',
        "https://bitbucket.org/o/r/src/topic/$file#lines-32"
    ],
    [
        'https://git.sr.ht/~o/r',
        "https://git.sr.ht/~o/r/tree/topic/item/$file#L32"
    ],
    [
        'https://git.example.com/o/r',
        "https://git.example.com/o/r/blob/topic/$file#L32"
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

    ( my $no_line = $expected ) =~ s{#.*}{};
    is(
        maybe_get_url_from_parsed_text( { file_name => $file } ),
        $no_line,
        "browse URL without a line anchor for $remote"
    );
}

done_testing();
