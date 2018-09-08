# frozen_string_literal: true

RSpec.describe Review::PullRequest do
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

  context 'POST /pr/assign' do
    let(:params) do
      { pull_request:
        { html_url: 'github.com/Jared-Prime/review/pulls/1',
          assignee: { login: 'Jared-Prime' },
          user: { login: 'Jared-Prime' } } }
    end

    it 'proxies message to Slack' do
      Timecop.freeze(Time.parse('2018-07-08 11:14:15')) do
        post '/pr/assign', params
      end

      expect(JSON.parse(last_response.body)).to include(
        'contents' => 'Jared assigned github.com/Jared-Prime/review/pulls/1 to Jared'
      )
    end
  end

  context 'POST /pr/review/request' do
    let(:params) do
      { pull_request: {
        html_url: 'github.com/Jared-Prime/review/pulls/1',
        user: { login: 'Jared-Prime' }
      },
        requested_reviewer: { login: 'somebody-else' } }
    end

    it 'proxies message to Slack' do
      Timecop.freeze(Time.parse('2018-07-08 11:14:15')) do
        post '/pr/review/request', params
      end

      expect(JSON.parse(last_response.body)).to include(
        'contents' => 'Jared needs somebody-else to review github.com/Jared-Prime/review/pulls/1'
      )
    end
  end

  context 'POST /pr/review/submit' do
    context 'default verbiage' do
      let(:params) do
        { pull_request:
          { html_url: 'github.com/Jared-Prime/review/pulls/1',
            user: { login: 'Jared-Prime' } },
          review: {
            body: 'good job!',
            user: { login: 'a friend' }
          } }
      end

      it 'proxies message to Slack' do
        Timecop.freeze(Time.parse('2018-07-08 11:14:15')) do
          post '/pr/review/submit', params
        end

        expect(JSON.parse(last_response.body)).to include(
          'contents' => "a friend has reviewed github.com/Jared-Prime/review/pulls/1 by Jared \n good job!"
        )
      end
    end

    context 'approved PR' do
      let(:params) do
        { pull_request:
          { html_url: 'github.com/Jared-Prime/review/pulls/1',
            user: { login: 'Jared-Prime' } },
          review: {
            state: 'approved',
            body: 'good job!',
            user: { login: 'a friend' }
          } }
      end

      it 'proxies message to Slack' do
        Timecop.freeze(Time.parse('2018-07-08 11:14:15')) do
          post '/pr/review/submit', params
        end

        expect(JSON.parse(last_response.body)).to include(
          'contents' => "a friend has approved github.com/Jared-Prime/review/pulls/1 by Jared \n good job!"
        )
      end
    end

    context 'change request' do
      let(:params) do
        { pull_request:
          { html_url: 'github.com/Jared-Prime/review/pulls/1',
            user: { login: 'Jared-Prime' } },
          review: {
            state: 'changes_requested',
            body: 'good job!',
            user: { login: 'a friend' }
          } }
      end

      it 'proxies message to Slack' do
        Timecop.freeze(Time.parse('2018-07-08 11:14:15')) do
          post '/pr/review/submit', params
        end

        expect(JSON.parse(last_response.body)).to include(
          'contents' => "a friend has requested changes on github.com/Jared-Prime/review/pulls/1 by Jared \n good job!"
        )
      end
    end
  end
end
