# oauth-client-sample

This is a sample [Cuba](http://cuba.is/) application that behaves as an OAuth client for AT&T M2X.

## Usage

- Clone the repository

```bash
git clone git@github.com:attm2x/oauth-client-sample.git
```

- Copy `settings.rb.sample` to `settings.rb` and edit it with your credentials
- Install `dep` if needed and run `dep install`

```bash
gem install dep
dep install
```

- Launch the application

```
rackup -p 8080 #
```

- Point your browser to `http://localhost:8080` and click on "Authorize me!"

Note that your OAuth client must have configured `http://localhost:8080/oauth/callback` as one of its `redirect_uris` for this application to work
