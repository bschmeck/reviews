# frozen_string_literal: true

RSpec.describe Review::Webhook do
  include Rack::Test::Methods

  def app
    described_class
  end

  let(:signature) do
    OpenSSL::HMAC.hexdigest(
      'sha1', '123456', Rack::Utils.build_nested_query(params)
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

      it 'returns a 201 with no action taken' do
        post '/webhook/github', params

        expect(last_response.status).to eq 201
        expect(last_response.body).to eq 'No configuration for `closed`. Dropping payload.'
      end
    end

    context 'for PR assignment event' do
      let(:params) do
        { pull_request:
          { html_url: 'github.com/Jared-Prime/review/pulls/1',
            assignee: { login: 'a friend' },
            user: { login: 'Jared-Prime' } },
          action: 'assigned' }
      end

      it 'delegates through to Slack' do
        Timecop.freeze(Time.parse('2018-07-08 11:14:15')) do
          post '/webhook/github', params
        end

        expect(JSON.parse(last_response.body)).to include(
          'contents' => 'Jared assigned github.com/Jared-Prime/review/pulls/1 to a friend'
        )
      end
    end

    context 'for PR review request event' do
      let(:params) do
        { pull_request: {
          html_url: 'github.com/Jared-Prime/review/pulls/1',
          user: { login: 'Jared-Prime' }
        },
          requested_reviewer: { login: 'a friend' },
          action: 'review_requested' }
      end

      it 'delegates through to Slack' do
        Timecop.freeze(Time.parse('2018-07-08 11:14:15')) do
          post '/webhook/github', params
        end

        expect(JSON.parse(last_response.body)).to include(
          'contents' => 'Jared needs a friend to review github.com/Jared-Prime/review/pulls/1'
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
            user: { login: 'a friend' }
          },
          action: 'submitted' }
      end

      it 'proxies message to Slack' do
        Timecop.freeze(Time.parse('2018-07-08 11:14:15')) do
          post '/webhook/github', params
        end

        expect(JSON.parse(last_response.body)).to include(
          'contents' => "a friend has reviewed github.com/Jared-Prime/review/pulls/1 by Jared \n good job!"
        )
      end
    end
  end
end
