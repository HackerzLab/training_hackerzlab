package TrainingHackerzlab::Util;
use Mojo::Base -base;
use Time::Piece;
use Exporter 'import';
our @EXPORT_OK = qw{
    now_datetime
};

# use TrainingHackerzlab::Util qw{now_datetime};
#
# '2017-11-11 13:43:10'
# my $datatime = now_datetime();
sub now_datetime {
    my $t    = localtime;
    my $date = $t->date;
    my $time = $t->time;
    return "$date $time";
}

1;
