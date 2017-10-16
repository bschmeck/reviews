# frozen_string_literal: true

RSpec.describe Review::PullRequest do
  include Rack::Test::Methods

  def app
    described_class
  end

  context 'POST /pr/assign' do
    let(:params) do
      { pull_request:
        { url: 'github.com/Jared-Prime/review/pulls/1',
          assignee: { login: 'Jared-Prime' },
          user: { login: 'Jared-Prime' } } }
    end

    it 'proxies message to Slack' do
      post '/pr/assign', params

      expect(JSON.parse(last_response.body)).to include(
        'contents' => 'Jared-Prime assigned github.com/Jared-Prime/review/pulls/1 to Jared-Prime'
      )
    end
  end

  context 'POST /pr/review/request' do
    let(:params) do
      { pull_request:
        { url: 'github.com/Jared-Prime/review/pulls/1',
          requested_reviewers: [
            { login: 'Jared-Prime' },
            { login: 'somebody-else' }
          ],
          user: { login: 'Jared-Prime' } } }
    end

    it 'proxies message to Slack' do
      post '/pr/review/request', params

      expect(JSON.parse(last_response.body)).to include(
        include('contents' => 'Jared-Prime needs Jared-Prime to review github.com/Jared-Prime/review/pulls/1'),
        include('contents' => 'Jared-Prime needs somebody-else to review github.com/Jared-Prime/review/pulls/1')
      )
    end
  end

  context 'POST /pr/review/approve' do
    let(:params) do
      { pull_request:
        { url: 'github.com/Jared-Prime/review/pulls/1',
          user: { login: 'Jared-Prime' } },
        review: {
          body: 'good job!',
          user: { login: 'Jared-Prime' }
        } }
    end

    it 'proxies message to Slack' do
      post '/pr/review/approve', params

      expect(JSON.parse(last_response.body)).to include(
        'contents' => "Jared-Prime has approved github.com/Jared-Prime/review/pulls/1 by Jared-Prime \n good job!"
      )
    end
  end
end
