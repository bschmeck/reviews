default: clean test server

lint:
	@time bundle exec rubocop

clean:
	@time bundle exec rubocop -a

test: lint bundle db-reset
	@time bundle exec rspec

test-live:
	@time curl -X POST https://pr-review-webhook.herokuapp.com/webhook/test -d '{ "message": "testing webhook" }'

bundle:
	@time bundle package --all

db-reset:
	@rm db/*.db
	$(MAKE) db-migrate

db-migrate:
	@time bundle exec sequel -m db/migration sqlite://db/alias.db

db-seed: db-migrate
	@time bundle exec ruby db/seed/aliases.rb

server:
	@SLACK_WEBHOOK=$(SLACK_WEBHOOK) bundle exec rackup