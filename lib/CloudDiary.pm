package CloudDiary;
use Mojo::Base 'Mojolicious', -signatures;

# This method will run once at server start
sub startup ($self) {

  # Load configuration from config file
  my $config = $self->plugin('NotYAMLConfig');

  # Configure the application
  $self->secrets($config->{secrets});

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('Example#welcome');
  $r->get('/diary')->to('Diary#list')->name('diary_list');
  $r->get('/diary/new')->to('Diary#create')->name('diary_create');
  $r->post('/diary/new')->to('Diary#post')->name('diary_post');
  $r->get('/diary/search')->to('Diary#search_form')->name('diary_search_form');
  $r->get('/diary/:id')->to('Diary#show')->name('diary_show');
  $r->get('/diary/:id/edit')->to('Diary#edit')->name('diary_edit');
  $r->get('/diary/:id/delete')->to('Diary#delete_confirm')->name('diary_delete_confirm');
  $r->post('/diary/:id/delete')->to('Diary#delete')->name('diary_delete');
}

1;
