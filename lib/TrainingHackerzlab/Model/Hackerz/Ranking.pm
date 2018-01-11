package TrainingHackerzlab::Model::Hackerz::Ranking;
use Mojo::Base 'TrainingHackerzlab::Model::Base';
use Mojo::Util qw{dumper};

use TrainingHackerzlab::Model::Hackerz::Answer;

sub index {
    my $self = shift;
    return;
}

# ランキング一覧画面
sub to_template_index {
    my $self = shift;
    warn 'to_template_index-----1';

    # 登録者の特典を個別に
    # 登録者をすべて
    my $cond = +{deleted => 0,};
    my @user_rows = $self->db->teng->search('user', $cond);

    # warn dumper @user_rows;
    # my $user_row = shift @user_rows;

    # ロジックを活用
    my $answer = TrainingHackerzlab::Model::Hackerz::Answer->new(conf => $self->conf);

    # my $params  = +{ user_id => $user_row->id, };
    # $answer->req_params($params);
    # my $to_template_score = $answer->to_template_score;

    # my $result = $to_template_score->{result};

    my $ranking_list = [];
    for my $user_row (@user_rows) {

        my $params = +{user_id => $user_row->id,};
        $answer->req_params($params);
        my $to_template_score = $answer->to_template_score;

        my $data = +{
            user_id  => $user_row->id,
            login_id => $user_row->login_id,
            name     => $user_row->name,
            score    => $to_template_score->{result},
        };

        push @{$ranking_list}, $data;

    }

    # warn dumper $ranking_list;

    my @sort = sort { $_->{score} <=> $_->{score} } @{$ranking_list};

    warn dumper @sort;
    my $int = 0;
    for my $sor (@sort) {
        $int += 1;
        $sor->{rank} = $int;
    }
    warn dumper @sort;
    return \@sort;

    # warn dumper $answer;
    # warn dumper $to_template_score;

    # my $think = +{
    #     question  => undef,
    #     hint_word => undef,
    #     hint_id   => undef,
    #     choice    => undef,
    #     survey    => undef,
    # };

    # my $cond = +{
    #     id      => $self->req_params->{question_id},
    #     deleted => 0,
    # };

    # # 存在しない問題の場合
    # $self->select_template('hackerz/question/not_found');

    # my $question_row = $self->db->teng->single( 'question', $cond );
    # return $think if !$question_row;
    # $think->{question} = $question_row->get_columns;

    # $self->_analysis_pattern($question_row);

    # # ヒント機能
    # my $hint_rows = $question_row->search_hint;
    # $think->{hint_word} = +{ map { $_->level => $_->hint } @{$hint_rows} };
    # $think->{hint_id}   = +{ map { $_->level => $_->id } @{$hint_rows} };

    # # 問題文に対して入力フォームにテキスト入力で解答
    # return $think if $self->is_question_form;

    # # 問題文に対して答えを4択から選択して解答
    # return $self->_create_choice_params( $question_row, $think )
    #     if $self->is_question_choice;

    # # 調査するページから解答を導き出して解答
    # return $self->_create_survey_params( $question_row, $think )
    #     if $self->is_question_survey;

    # # 調査するページとファイルダウンロード
    # return $self->_create_survey_params( $question_row, $think )
    #     if $self->is_question_survey_and_file;

    # # 問題と詳細から解答を導き出してテキスト入力で解答
    # return $think if $self->is_question_explain;

    # return $think;
}

1;
