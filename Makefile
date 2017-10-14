default: clean test server

lint:
	@time bundle exec rubocop

clean:
	@time bundle exec rubocop -a

test: lint bundle
	@time bundle exec rspec

bundle:
	@time bundle package --all

server:
	@bundle exec rackup
