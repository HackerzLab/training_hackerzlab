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
        my $question = $collected_sort->fetch_question;
        my $data     = $question->get_columns;
        $data->{sort_id}      = $collected_sort->sort_id;
        $data->{collected_id} = $collected_sort->collected_id;

        # 短くした問題文章
        $data->{short_question} = substr( $data->{question}, 0, 20 ) . ' ...';

        # 問題の解答状況
        $data->{how}      = '未';
        $data->{how_text} = 'primary';

        my $answer = $question->fetch_answer( $self->req_params->{user_id} );
        if ($answer) {
            $data->{how}      = '不正解';
            $data->{how_text} = 'danger';
            if ( $answer->user_answer eq $question->answer ) {
                $data->{how}      = '正解';
                $data->{how_text} = 'success';
            }
        }
        push @{$collected_list}, $data;
    }
    $show->{collected_list} = $collected_list;
    return $show;
}

1;
