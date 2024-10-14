package CloudDiary::Controller::Diary;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use POSIX qw(strftime);
use CloudDiary::DB::Conn;

my $handle = CloudDiary::DB::Conn::make_handle();

# This action will render a template
sub list ($self) {
  my $stmt = $handle->prepare('SELECT id,date,content,rating FROM diaries ORDER BY DATE(`date`) DESC LIMIT 10');
  $stmt->execute();

  my @diaries;
  while (my $row = $stmt->fetchrow_hashref) {
    my $id = $row->{id};
    my $title = $row->{date};
    my $content = $row->{content};
    my $rating = $row->{rating};

    push @diaries, {id => $id, title => $title, content => $content, rating => $rating};
  }

  # Render template "example/welcome.html.ep" with message
  $self->render(diaries => \@diaries, mode => 'list');
}

sub create ($self) {
  my $date = $self->param('date');

  if (defined $date) {
    # 既存の日記がないか検索
    my $stmt = $handle->prepare('SELECT date,content,rating FROM diaries WHERE date=?');
    my @params = ($date);
    $stmt->execute(@params);

    my $row = $stmt->fetchrow_hashref;
    if ($row) {
      my $date = $row->{date};
      my $content = $row->{content};
      my $rating = $row->{rating};

      $self->render(date => $date, content => $content, rating => $rating);
    } else {
      $self->render(date => $date, content => '', rating => '');
    }
  } else {
    # 日付未選択
    $self->render(template => 'diary/create_pre');
  }
}

sub edit ($self) {
  my $id = $self->param('id');

  my $stmt = $handle->prepare('SELECT date,content,rating FROM diaries WHERE id=?');
  my @params = ($id);
  $stmt->execute(@params);

  my $row = $stmt->fetchrow_hashref;
  if ($row) {
    my $date = $row->{date};
    my $content = $row->{content};
    my $rating = $row->{rating};

    $self->render(template => 'diary/create', date => $date, content => $content, rating => $rating);
  } else {
    $self->render(text => 'Not Found', status => 404);
  }
}

sub post ($self) {
  my $date = $self->param('date');
  my $rating = $self->param('rating');
  my $content = $self->param('content');
  my $time_string = strftime "%Y/%m/%d", localtime;
  
  my $stmt = $handle->prepare('INSERT INTO diaries (date, created_at, content, rating) VALUES (?, CURRENT_TIMESTAMP, ?, ?) ON CONFLICT(date) DO UPDATE SET created_at=CURRENT_TIMESTAMP, content=?, rating=?');
  my @params = ($date, $content, $rating, $content, $rating);
  $stmt->execute(@params);

  $self->render(template => 'diary/show', id => undef, title => $time_string, rating => $rating, content => $content);
}

sub show ($self) {
  my $id = $self->param('id');

  my $stmt = $handle->prepare('SELECT date,content,rating FROM diaries WHERE id=?');
  my @params = ($id);
  $stmt->execute(@params);

  my $row = $stmt->fetchrow_hashref;
  if ($row) {
    my $title = $row->{date};
    my $content = $row->{content};
    my $rating = $row->{rating};

    $self->render(title => $title, content => $content, rating => $rating);
  } else {
    $self->render(text => 'Not Found', status => 404);
  }
}

sub delete_confirm($self) {
  my $id = $self->param('id');

  my $stmt = $handle->prepare('SELECT date FROM diaries WHERE id=?');
  my @params = ($id);
  $stmt->execute(@params);

  my $row = $stmt->fetchrow_hashref;
  if ($row) {
    my $date = $row->{date};

    $self->render(date => $date);
  } else {
    $self->render(text => 'Not Found', status => 404);
  }
}

sub delete ($self) {
  my $id = $self->param('id');

  my $stmt = $handle->prepare('DELETE FROM diaries WHERE id=?');
  my @params = ($id);
  $stmt->execute(@params);

  $self->redirect_to('diary_list');
}

sub search ($self, $date) {
  my $stmt = $handle->prepare('SELECT id,date,content,rating FROM diaries WHERE date=?');
  my @params = ($date);
  $stmt->execute(@params);

  my @diaries;
  while (my $row = $stmt->fetchrow_hashref) {
    my $id = $row->{id};
    my $title = $row->{date};
    my $content = $row->{content};
    my $rating = $row->{rating};

    push @diaries, {id => $id, title => $title, content => $content, rating => $rating};
  }

  $self->render(template => 'diary/list', diaries => \@diaries, mode => 'search');
}

sub search_form ($self) {
  my $params = $self->req->params->to_hash;

  if (%$params) {
    my $date = $params->{date};
    $self->search($date);
  } else {
    # no search condition
    $self->render(template => 'diary/search');
  }
}

1;
