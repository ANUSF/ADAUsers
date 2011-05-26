#Themenap::Config.server = 'http://178.79.149.181'
Themenap::Config.server = 'http://test.ada.edu.au'
Themenap::Config.verify_ssl = false # while we're not using a proper certificate
Themenap::Config.use_basic_auth = true
Themenap::Config.snippets =
  [ { :css => 'title',
      :text => 'ADA Users <%= yield :title %>' },
    { :css => 'head:first',
      :text => '<%= render "layouts/includes" %>',
      :mode => :append },
    { :css => 'meta[name=csrf-param]',
      :mode => :remove },
    { :css => 'meta[name=csrf-token]',
      :mode => :remove },
    { :css => 'body',
      :mode => :setattr, :key => 'id', :value => 'social_science' },
    { :css => '.masthead',
      :mode => :setattr, :key => 'class', :value => 'masthead{{= yield :masthead_class }}' },
    { :css => 'section.content nav', :text => '' },
    { :css => 'article',
      :text => '<%= render "layouts/body" %>' },
    { :css => 'nav.subnav',
      :text => '<%= render "layouts/links" %>' },
    { :css => '.login',
      :text => '<%= render "layouts/login" %>' } ]
Themenap::Config.layout_name = 'ada'
