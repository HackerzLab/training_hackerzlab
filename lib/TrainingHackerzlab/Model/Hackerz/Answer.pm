package TrainingHackerzlab::Model::Hackerz::Answer;
use Mojo::Base 'TrainingHackerzlab::Model::Base';

has [qw{error_msg}] => undef;

# 簡易的なバリデート
sub has_error_easy {
    my $self   = shift;
    my $params = $self->req_params;
    my $master = $self->db->master;
    $self->error_msg($master->answer->to_word('NOT_INPUT'));
    return 1 if !$params->{user_id};
    return 1 if !$params->{user_answer};
    return 1 if !$params->{question_id};

    # 二重登録防止
    my $cond = +{
        user_id     => $params->{user_id},
        question_id => $params->{question_id},
        deleted     => $self->db->master->deleted->constant('NOT_DELETED'),
    };
    my $answer = $self->db->teng->single('answer', $cond);
    $self->error_msg($master->answer->to_word('EXISTS_ANSWER'));
    return 1 if $answer;
    $self->error_msg(undef);
    return;
}

# 登録実行
sub store {
    my $self   = shift;
    my $master = $self->db->master;
    my $params = +{
        question_id => $self->req_params->{question_id},
        user_id     => $self->req_params->{user_id},
        user_answer => $self->req_params->{user_answer},
        deleted     => $master->deleted->constant('NOT_DELETED'),
    };
    return $self->db->teng_fast_insert('answer', $params);
}

sub to_template_list {
    my $self   = shift;
    my $master = $self->db->master;
    my $list   = +{answers => [],};

    my $cond = +{
        id      => $self->req_params->{user_id},
        deleted => $master->deleted->constant('NOT_DELETED'),
    };
    my $user_row = $self->db->teng->single('user', $cond);
    return $list if !$user_row;

    my $answer_rows = $user_row->search_answer;
    return $list if !$answer_rows;

    $list->{answers} = [map { $_->get_columns } @{$answer_rows}];
    return $list;
}

sub to_template_result {
    my $self   = shift;
    my $master = $self->db->master;
    my $result = +{};

    my $cond = +{
        id      => $self->req_params->{answer_id},
        deleted => 0,
    };

    my $answer_row = $self->db->teng->single('answer', $cond);
    return if !$answer_row;
    $result->{answer} = $answer_row->get_columns;

    my $question_row = $answer_row->fetch_question;

    if ($answer_row->user_answer eq $question_row->answer) {
        $result->{result} = '正解だ！';
    }
    else {
        $result->{result} = '間違いだ！';
    }

    # 次の問題
    my $question_id = $question_row->id;
    $question_id += 1;
    $result->{next_question_id} = $question_id;

    return $result;
}

1;
