use strict;
use warnings;
package Open::This;

sub to_file {
    my $text = shift;

    #at lib/Foo/Bar.pm line 222.
    if ( $text =~ m{\b([^\s]*\.pm) line (\d*)} ) {
        return { file_name => $1, line_number => $2 };
    }
    return undef;
}

1;
