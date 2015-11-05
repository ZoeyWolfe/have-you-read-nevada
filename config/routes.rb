Rails.application.routes.draw do
  get 'pdf'  => 'nevada#pdf'
  get 'epub'  => 'nevada#epub'
  get 'mobi'  => 'nevada#mobi'

  root 'welcome#index'

  get '*path' => redirect('/')
end
