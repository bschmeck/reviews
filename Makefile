default: clean test server

lint:
	@time bundle exec rubocop

clean:
	@time bundle exec rubocop -a

test: lint bundle
	@time bundle exec rspec

test-live:
	@time curl -X POST https://pr-review-webhook.herokuapp.com/webhook/test -d '{ "message": "testing webhook" }'

bundle:
	@time bundle package --all

server:
	@bundle exec rackup
