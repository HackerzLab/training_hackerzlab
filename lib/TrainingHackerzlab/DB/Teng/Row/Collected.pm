package TrainingHackerzlab::DB::Teng::Row::Collected;
use Mojo::Base 'Teng::Row';

# 該当の問題の順番を取得
sub fetch_collected_sorts {
    my $self = shift;
    my $cond = +{ collected_id => $self->id, deleted => 0, };
    my $attr = +{ order_by => 'sort_id ASC' };
    my @collected_sorts
        = $self->handle->search( 'collected_sort', $cond, $attr );
    return \@collected_sorts;
}

1;

__END__
