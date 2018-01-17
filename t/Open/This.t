use strict;
use warnings;

use Open::This;
use Test::More;

is_deeply(
    Open::This::to_file('at lib/Foo/Bar.pm line 222.'),
    { file_name => 'lib/Foo/Bar.pm', line_number => 222, },
    'line 222'
);

done_testing();
