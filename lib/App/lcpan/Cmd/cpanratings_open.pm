package App::lcpan::Cmd::cpanratings_open;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;
use Log::ger;

require App::lcpan;

our %SPEC;

$SPEC{handle_cmd} = {
    v => 1.1,
    summary => 'Open CPAN Ratings page for dist/module',
    description => <<'_',

Given distribution `DIST` (or module `MOD`), this will open
https://cpanratings.perl.org/dist/DIST. `DIST` will first be checked for
existence in local index database.

_
    args => {
        %App::lcpan::common_args,
        %App::lcpan::mod_or_dist_args,
    },
};
sub handle_cmd {
    my %args = @_;

    my $state = App::lcpan::_init(\%args, 'ro');
    my $dbh = $state->{dbh};

    my ($dist, $file_id, $cpanid, $version);
    {
        # first find dist
        if (($file_id, $cpanid, $version) = $dbh->selectrow_array(
            "SELECT file_id, cpanid, version FROM dist WHERE name=? AND is_latest", {}, $args{module_or_dist})) {
            $dist = $args{module_or_dist};
            last;
        }
        # try mod
        if (($file_id, $dist, $cpanid, $version) = $dbh->selectrow_array("SELECT m.file_id, d.name, d.cpanid, d.version FROM module m JOIN dist d ON m.file_id=d.file_id WHERE m.name=?", {}, $args{module_or_dist})) {
            last;
        }
    }
    $file_id or return [404, "No such module/dist '$args{module_or_dist}'"];

    require Browser::Open;
    my $err = Browser::Open::open_browser("https://cpanratings.perl.org/dist/$dist");
    return [500, "Can't open browser"] if $err;
    [200];
}

1;
# ABSTRACT:
