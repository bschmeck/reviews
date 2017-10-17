# frozen_string_literal: true

RSpec.describe Review::Webhook do
  include Rack::Test::Methods

  def app
    described_class
  end

  let(:signature) do
    OpenSSL::HMAC.hexdigest(
      'sha1', ENV['WEBHOOK_SECRET_TOKEN'], Rack::Utils.build_nested_query(params)
    )
  end

  before do
    header 'X-Hub-Signature', "sha=#{signature}"
  end

  context 'POST /webhook/github' do
    context 'for uninteresting event' do
      let(:params) do
        { pull_request:
          { html_url: 'github.com/Jared-Prime/review/pulls/1',
            assignee: 'Jared-Prime',
            user: { login: 'Jared-Prime' } },
          action: 'closed' }
      end

      it 'returns a 304 with no action taken' do
        post '/webhook/github', params

        expect(last_response.status).to eq 304
        expect(last_response.body).to include 'No action taken'
      end
    end

    context 'for PR assignment event' do
      let(:params) do
        { pull_request:
          { html_url: 'github.com/Jared-Prime/review/pulls/1',
            assignee: { login: 'Jared-Prime' },
            user: { login: 'Jared-Prime' } },
          action: 'assigned' }
      end

      it 'delegates through to Slack' do
        post '/webhook/github', params

        expect(JSON.parse(last_response.body)).to include(
          'contents' => 'Jared assigned github.com/Jared-Prime/review/pulls/1 to Jared'
        )
      end
    end

    context 'for PR review request event' do
      let(:params) do
        { pull_request:
          { html_url: 'github.com/Jared-Prime/review/pulls/1',
            requested_reviewers: [
              { login: 'Jared-Prime' },
              { login: 'somebody-else' }
            ],
            user: { login: 'Jared-Prime' } },
          action: 'review_requested' }
      end

      it 'delegates through to Slack' do
        post '/webhook/github', params

        expect(JSON.parse(last_response.body)).to include(
          include('contents' => 'Jared needs Jared to review github.com/Jared-Prime/review/pulls/1'),
          include('contents' => 'Jared needs somebody-else to review github.com/Jared-Prime/review/pulls/1')
        )
      end
    end

    context 'for PR approval event' do
      let(:params) do
        { pull_request:
          { html_url: 'github.com/Jared-Prime/review/pulls/1',
            user: { login: 'Jared-Prime' } },
          review: {
            body: 'good job!',
            user: { login: 'Jared-Prime' }
          },
          action: 'submitted' }
      end

      it 'proxies message to Slack' do
        post '/webhook/github', params

        expect(JSON.parse(last_response.body)).to include(
          'contents' => "Jared has approved github.com/Jared-Prime/review/pulls/1 by Jared \n good job!"
        )
      end
    end
  end
end
