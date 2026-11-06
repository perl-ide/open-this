use strict;
use warnings;

use Open::This        qw( maybe_get_url_from_parsed_text to_editor_args );
use Test::Differences qw( eq_or_diff );
use Test::More import => [qw( done_testing is )];
use Test::Needs    qw( Git::Helpers );
use Test::Warnings ();
use URI            ();

# This gets really noisy on Travis if $ENV{EDITOR} is not set
local $ENV{EDITOR} = 'vim';

{
    no warnings 'redefine';
    local *Git::Helpers::current_branch_name = sub { 'main' };

    local *Git::Helpers::https_remote_url = sub {
        URI->new('https://codeberg.org/demiguise/Dancer2-Plugin-Feed');
    };
    is(
        maybe_get_url_from_parsed_text(
            { file_name => 'lib/Open/This.pm', line_number => 32 }
        ),
        'https://codeberg.org/demiguise/Dancer2-Plugin-Feed/src/branch/main/lib/Open/This.pm#L32',
        'Codeberg browse URL uses src/branch'
    );

    local *Git::Helpers::https_remote_url
        = sub { URI->new('https://github.com/oalders/open-this') };
    is(
        maybe_get_url_from_parsed_text(
            { file_name => 'lib/Open/This.pm', line_number => 32 }
        ),
        'https://github.com/oalders/open-this/blob/main/lib/Open/This.pm#L32',
        'GitHub browse URL still uses blob'
    );
}

eq_or_diff(
    [
        to_editor_args(
            'https://codeberg.org/oalders/open-this/src/branch/main/lib/Open/This.pm#L75'
        )
    ],
    [ '+75', 'lib/Open/This.pm' ],
    'full https Codeberg URL with fragment'
);

done_testing();
