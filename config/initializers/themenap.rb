Themenap::Config.configure do |c|
  c.server = 'https://staff.ada.edu.au'
  c.use_basic_auth = true
  c.snippets =
    [ { :css => 'title',
        :text => 'ADA Users <%= yield :title %>' },
      { :css => 'head:first',
        :text => '<%= render "layouts/includes" %>',
        :mode => :append },
      { :css => 'meta[name=csrf-param]',
        :mode => :remove },
      { :css => 'meta[name=csrf-token]',
        :mode => :remove },
      { :css => 'nav.archive_menu',
        :mode => :remove },
      { :css => 'body',
        :mode => :setattr,
        :key => 'id',
        :value => 'social_science' },
      { :css => '.masthead',
        :mode => :setattr,
        :key => 'class',
        :value => 'masthead{{= yield :masthead_class }}' },
      { :css => 'section.content nav', :text => '' },
      { :css => 'article',
        :text => '<%= render "layouts/body" %>' },
      { :css => 'nav.subnav',
        :text => '<%= render "layouts/links" %>' },
      { :css => '.login',
        :text => '<%= render "layouts/login" %>' } ]
  c.layout_name = 'ada'
end
