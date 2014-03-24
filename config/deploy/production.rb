set :stage, :production


server 'localhost',
  user: 'stefan',
  roles: %w{web app db},
  ssh_options: {
    user: 'stefan', # overrides user setting above
    keys: %w(~/.ssh/id_rsa),
    forward_agent: false,
    auth_methods: %w(publickey password)
  }
