use strict;
use warnings;
package Open::This;

use Path::Tiny qw( path );

## no critic (Subroutines::ProhibitExplicitReturnUndef)

sub to_file {
    my $text = shift;

    return undef if !$text;

    if ( -e path($text) ) {
        return { file_name => $text };
    }
    if ( $text =~ m{::} ) {
        my @parts = split m{::}, $text;
        my $sub_name;
        if ( $parts[-1] =~ m{\(} ) {
            $sub_name = pop @parts;
            $sub_name =~ s{[\(\)]}{}g;
        }
        $parts[-1] = $parts[-1] . '.pm';
        my $file_name;
        my $line_number;

        for my $dir ( 'lib', 't/lib' ) {
            my $path = path( $dir, @parts );
            if ( -e $path ) {
                $file_name = "$path";
                last;
            }
        }

        if ( $file_name && $sub_name ) {
            my $grep = `grep --line-number "sub $sub_name" $file_name`;
            my @results = split m{:}, $grep;
            $line_number = shift @results;
        }

        return $file_name
            ? {
            file_name   => $file_name,
            line_number => $line_number,
            $sub_name ? ( sub_name => $sub_name ) : (),
            }
            : undef;
    }

    #  lib/Foo/Bar.pm line 222.
    # /lib/Foo/Bar.pm line 222.
    if ( $text =~ m{([^\s]*) line (\d*)} ) {
        return { file_name => $1, line_number => $2 };
    }

    # git-grep
    if ( $text =~ m{\b([^\s]*):(\d*)\b} ) {
        return { file_name => $1, line_number => $2 };
    }

    return undef;
}

sub to_editor_args {
    my $text = shift;
    return undef unless $text;

    my $found = to_file($text);

    # Maybe this file is just being created
    return $text unless $found;

    return (
        ( $found->{line_number} ? '+' . $found->{line_number} : () ),
        $found->{file_name}
    );
}

# ABSTRACT: Try to Do the Right Thing when opening files
1;

=pod

=head1 DESCRIPTION

This module powers the C<ot> command line script, which tries to do the right
thing when opening a file.  Imagine your C<$EDITOR> env var is set to C<vim>.

    ot Foo::Bar # vim lib/Foo/Bar.pm
    ot Foo::Bar # vim t/lib/Foo/Bar.pm

Imagine this module has a sub called do_something at line 55.
    ot "Foo::Bar::do_something()" # vim +55 lib/Foo/Bar.pm

Or, when copy/pasting from a stack trace:
    ot "Foo::Bar line 36" # vim +36 lib/Foo/Bar.pm

Copy/pasting a C<git-grep> result:
    ot "Foo/Bar.pm:99" # vim +99 Foo/Bar.pm

=cut
