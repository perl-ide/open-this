package OtBrowseStub;

use strict;
use warnings;

use URI ();

# Preloaded so --browse tests need no git checkout and never start a browser.
$INC{'Browser/Open.pm'} = $INC{'Git/Helpers.pm'} = __FILE__;

sub Browser::Open::open_browser {
    print STDOUT shift, "\n";
}

sub Git::Helpers::https_remote_url {
    return URI->new('https://github.com/o/r');
}

sub Git::Helpers::current_branch_name {
    return 'topic';
}

1;
