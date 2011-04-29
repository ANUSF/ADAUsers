Themenap::Config.server = 'http://testada'
Themenap::Config.snippets =
  [ { :css => 'title',
      :text => 'ADA Users <%= yield :title %>' },
    { :css => 'head:first',
      :text => '<%= render "layouts/includes" %>',
      :mode => :append },
    { :css => 'body',
      :mode => :setattr, :key => 'id', :value => 'social_science' },
    { :css => 'section.content nav', :text => '' },
    { :css => 'article',
      :text => '<%= render "layouts/body" %>' },
    { :css => 'nav.subnav',
      :text => '<%= render "layouts/links" %>' },
    { :css => '.login',
      :text => '<%= render "layouts/login" %>' } ]
Themenap::Config.layout_name = 'ada'
