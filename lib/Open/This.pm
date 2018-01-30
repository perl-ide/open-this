use strict;
use warnings;
package Open::This;

use Path::Tiny qw( path );

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

    ## no critic (Subroutines::ProhibitExplicitReturnUndef)
    return undef;
}

sub to_vim {
    my $text = shift;
    return undef unless $text;

    my $found = to_file($text);

    # Maybe this file is just being created
    return $text unless $found;

    my @command = (
        ( $found->{line_number} ? '+' . $found->{line_number} : () ),
        $found->{file_name}
    );
    return join q{ }, @command;
}

# ABSTRACT: Try to Do the Right Thing when opening files
1;
