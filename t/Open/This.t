use strict;
use warnings;

use Open::This;
use Test::More;

is_deeply(
    Open::This::to_file('at lib/Foo/Bar.pm line 222.'),
    { file_name => 'lib/Foo/Bar.pm', line_number => 222, },
    'line 222'
);

is_deeply(
    Open::This::to_file('Foo::Bar::do_something()'),
    {
        file_name   => 't/lib/Foo/Bar.pm',
        line_number => 3,
        sub_name    => 'do_something',
    },
    'line 3'
);

is_deeply(
    Open::This::to_file('foo/bar/baz.html.ep line 5. Blah'),
    {
        file_name   => 'foo/bar/baz.html.ep',
        line_number => 5,
    },
    'line 3 in Mojo template'
);

is_deeply(
    Open::This::to_file('t/lib/Foo/Bar.pm:32:'),
    {
        file_name   => 't/lib/Foo/Bar.pm',
        line_number => 32,
    },
    'results from git-grep'
);

is_deeply(
    Open::This::to_file('t/Does/Not/Exist'),
    undef,
    'undef on not found file'
);

is_deeply(
    Open::This::to_file('X::Y'),
    undef,
    'undef on not found module'
);

is(
    Open::This::to_vim('Foo::Bar::do_something()'),
    'vim +3 t/lib/Foo/Bar.pm', 'open in vim on line 3'
);
done_testing();