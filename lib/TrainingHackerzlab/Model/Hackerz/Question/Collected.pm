package TrainingHackerzlab::Model::Hackerz::Question::Collected;
use Mojo::Base 'TrainingHackerzlab::Model::Base';
use Mojo::Util qw{dumper};

sub to_template_show {
    my $self = shift;
    my $show = +{
        collected     => undef,
        question_list => undef,
    };

    my $cond = +{
        id      => $self->req_params->{collected_id},
        deleted => 0,
    };

    my $collected_row = $self->db->teng->single( 'collected', $cond );
    return $show if !$collected_row;
    $show->{collected} = $collected_row->get_columns;

    # my $show = +{
    #     collected => +{},
    #     question_list => [
    #         +{  collected_sort => +{},
    #             question => +{},
    #             answer => +{},
    #             q_url => '',
    #             how => '',
    #             how_text => '',
    #         },
    #     ],
    # };
    my $question_list = $collected_row->fetch_question_list_to_hash(
        $self->req_params->{user_id} );

    # 問題集の順番も含める
    for my $list ( @{$question_list} ) {
        my $sort_id      = $list->{collected_sort}->{sort_id};
        my $collected_id = $list->{collected_sort}->{collected_id};
        $list->{sort_id}      = $sort_id;
        $list->{collected_id} = $collected_id;

        # 短くした問題文章
        $list->{short_question}
            = substr( $list->{question}->{question}, 0, 20 ) . ' ...';

        # 問題へのurl
        $list->{q_url}
            = "/hackerz/question/collected/$collected_id/$sort_id/think";

        # 問題の解答状況
        $list->{how}      = '未';
        $list->{how_text} = 'primary';

        if ( exists $list->{answer} ) {
            $list->{how}      = '不正解';
            $list->{how_text} = 'danger';
            if ( $list->{answer}->{user_answer} eq $list->{question}->{answer}
                )
            {
                $list->{how}      = '正解';
                $list->{how_text} = 'success';
            }
        }
    }
    $show->{question_list} = $question_list;
    return $show;
}

1;
