package TrainingHackerzlab::Model::Hackerz::Question;
use Mojo::Base 'TrainingHackerzlab::Model::Base';
use TrainingHackerzlab::Model::Hackerz::Question::Collected;

has collected => sub {
    TrainingHackerzlab::Model::Hackerz::Question::Collected->new(
        +{ conf => shift->conf } );
};

has [
    qw{is_question_choice is_question_form is_question_survey
        is_question_survey_and_file is_question_explain select_template}
] => undef;

# 問題をとくんだな画面
sub to_template_index {
    my $self = shift;

    my $template_index = +{ question_list => undef, };

    my $cond = +{ deleted => 0, };

    my @question_rows = $self->db->teng->search( 'question', $cond );
    return $template_index if scalar @question_rows eq 0;

    my $question_list;
    for my $question (@question_rows) {
        my $data = $question->get_columns;
        $data->{sort_id} = $question->id;

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
        push @{$question_list}, $data;
    }
    $template_index->{question_list} = $question_list;
    return $template_index;
}

# 問題画面パラメーター
sub to_template_think {
    my $self = shift;

    my $think = +{
        question        => undef,
        is_answer_ended => undef,
        collected       => undef,
        collected_sort  => undef,
        collected_url   => '/hackerz/question',
        sort_id         => undef,
        hint_word       => undef,
        hint_id         => undef,
        choice          => undef,
        survey          => undef,
    };

    my $cond = +{
        id      => $self->req_params->{question_id},
        deleted => 0,
    };

    # 存在しない問題の場合
    $self->select_template('hackerz/question/not_found');

    # 問題集からの呼び出しに対応
    if ( !$cond->{id} ) {
        my $sort_cond = +{
            collected_id => $self->req_params->{collected_id},
            sort_id      => $self->req_params->{sort_id},
            deleted      => 0,
        };
        my $collected_sort_row
            = $self->db->teng->single( 'collected_sort', $sort_cond );
        return $think if !$collected_sort_row;
        $cond->{id} = $collected_sort_row->question_id;
        $think->{collected}
            = $collected_sort_row->fetch_collected->get_columns;
        $think->{collected_url}
            .= '/collected/' . $self->req_params->{collected_id};
        $think->{collected_sort} = $collected_sort_row->get_columns;
        $think->{sort_id}        = $collected_sort_row->sort_id;
    }

    my $question_row = $self->db->teng->single( 'question', $cond );
    return $think if !$question_row;
    $think->{question} = $question_row->get_columns;

    if ( !$think->{sort_id} ) {
        $think->{sort_id} = $question_row->id;
    }

    # 解答ずみかであるかの確認
    $think->{is_answer_ended}
        = $question_row->is_answer_ended( $self->req_params->{user_id} );

    $self->_analysis_pattern($question_row);

    # ヒント機能
    my $hint_rows = $question_row->search_hint;
    $think->{hint_word} = +{ map { $_->level => $_->hint } @{$hint_rows} };
    $think->{hint_id}   = +{ map { $_->level => $_->id } @{$hint_rows} };

    # 問題文に対して入力フォームにテキスト入力で解答
    return $think if $self->is_question_form;

    # 問題文に対して答えを4択から選択して解答
    return $self->_create_choice_params( $question_row, $think )
        if $self->is_question_choice;

    # 調査するページから解答を導き出して解答
    return $self->_create_survey_params( $question_row, $think )
        if $self->is_question_survey;

    # 調査するページとファイルダウンロード
    return $self->_create_survey_params( $question_row, $think )
        if $self->is_question_survey_and_file;

    # 問題と詳細から解答を導き出してテキスト入力で解答
    return $think if $self->is_question_explain;
    return $think;
}

# 選択する答えのリスト
sub _create_choice_params {
    my $self        = shift;
    my $row         = shift;
    my $think       = shift;
    my $choice_rows = $row->search_choice;
    my $choice      = +{};
    for my $choice_row ( @{$choice_rows} ) {
        $choice->{ $choice_row->answer_val } = $choice_row->answer_text;
    }
    $think->{choice} = $choice;
    return $think;
}

# 調査するページの情報
sub _create_survey_params {
    my $self       = shift;
    my $row        = shift;
    my $think      = shift;
    my $survey_row = $row->fetch_survey;
    return $think if !$survey_row;
    $think->{survey} = $survey_row->get_columns;
    return $think;
}

sub _analysis_pattern {
    my $self = shift;
    my $row  = shift;
    $self->select_template(undef);

    # form -> 問題文に対して入力フォームにテキスト入力
    if ( $row->pattern eq 10 ) {
        $self->is_question_form(1);
        $self->select_template('/hackerz/question/form');
        return;
    }

    # choice -> 問題文に対して答えを4択から選択して解答
    if ( $row->pattern eq 20 ) {
        $self->is_question_choice(1);
        $self->select_template('/hackerz/question/choice');
        return;
    }

    # survey -> 調査するページから解答を導き出して入力
    if ( $row->pattern eq 30 ) {
        $self->is_question_survey(1);
        $self->select_template('/hackerz/question/survey');
        return;
    }

    # survey_and_file -> 調査するページとファイル
    if ( $row->pattern eq 31 ) {
        $self->is_question_survey_and_file(1);
        $self->select_template('/hackerz/question/survey_and_file');
        return;
    }

    # explain -> 問題とその詳細から解答を導き出して入力
    if ( $row->pattern eq 40 ) {
        $self->is_question_explain(1);
        $self->select_template('/hackerz/question/explain');
        return;
    }

    # どれにも当てはまらない場合
    $self->select_template('hackerz/question/not_found');
    return;
}

1;
