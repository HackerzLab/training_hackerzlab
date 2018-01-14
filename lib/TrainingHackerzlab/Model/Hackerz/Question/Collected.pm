package TrainingHackerzlab::Model::Hackerz::Question::Collected;
use Mojo::Base 'TrainingHackerzlab::Model::Base';
use Mojo::Util qw{dumper};

sub to_template_show {
    my $self = shift;
    my $show = +{
        collected      => undef,
        collected_list => undef,
    };

    my $cond = +{
        id      => $self->req_params->{collected_id},
        deleted => 0,
    };

    my $collected_row = $self->db->teng->single( 'collected', $cond );
    return $show if !$collected_row;
    $show->{collected} = $collected_row->get_columns;

    # 問題集の順番も含める
    my $collected_sorts = $collected_row->fetch_collected_sorts;
    my $collected_list;
    for my $collected_sort ( @{$collected_sorts} ) {
        my $data = $collected_sort->fetch_question->get_columns;
        $data->{sort_id} = $collected_sort->sort_id;

        # 短くした問題文章
        $data->{short_question} = substr( $data->{question}, 0, 20 ) . ' ...';
        push @{$collected_list}, $data;
    }
    $show->{collected_list} = $collected_list;
    return $show;
}

1;
