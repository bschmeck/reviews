# you too can robit with this three easy steps!

## Create Slack App

Slacking off works best with automation.

1. Create a new app in Slack ~> https://api.slack.com/apps
2. Configure to use Incoming Webhooks
3. Add app webhook to your workspace
$. Copy the webhook URI

## Create Review Server

You're a clever girl or guy. You can do this.

1. Run redis. If you don't, the robit will run, but they might forget things and you probably will get duplicate messages.
2. Add the following configuration variables to your server
  - RACK_ENV=production
  - REDIS_URL=[whereever]
  - SLACK_WEBHOOK=[from step 4 above]
  - USERNAME_ALIASES=config/aliases.yml
  - WEBHOOK_SECRET_TOKEN=[try $(ruby -e "require 'securerandom'; puts SecureRandom.uuid")]
4. commit your custom `config/aliases.yml` and `config/settings.yml` to your deploy branch.
5. deploy
6. Run rack: `bundle exec rackup config.ru`

## Create Github Webhook

Gotta git that hook to you're server!

1. Add a webhook for the project you wish to publish reviews
2. Use `[YOUR_ADDRESS]/webhook/github` as the payload URL
3. Choose `application/json` for content type.
4. Supply the secret from above.

Huzzah. Maybe robit needs more than three steps, but they're all easy so there.