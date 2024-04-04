use strict;
use warnings;

use Test::More import => [qw( done_testing subtest )];
use Test::Script qw( script_runs script_stdout_is );

subtest 'print' => sub {
    my @args = (
        [ '--print', '--editor' ],
        [ '-p',      '-e' ],
        [ '-p',      '--editor' ],
        [ '--print', '-e' ],
    );

    for my $args (@args) {
        script_runs(
            [ './script/ot', @$args, 'kate', 'Open::This line 222' ] );
        my $test_name = join ' ', @$args;
        script_stdout_is( "--line 222 lib/Open/This.pm\n", $test_name );
    }
};

subtest 'json' => sub {
    my @args = (
        [ '--json', '--editor' ],
        [ '-j',     '-e' ],
        [ '-j',     '--editor' ],
        [ '--json', '-e' ],
    );

    for my $args (@args) {
        script_runs(
            [ './script/ot', @$args, 'kate', 'Open::This line 222' ] );
        my $test_name = join ' ', @$args;
        script_stdout_is(
            '{"editor":"kate","editor_args":["--line","222","lib/Open/This.pm"],"success":true}'
                . "\n", $test_name );
    }
};

done_testing;
