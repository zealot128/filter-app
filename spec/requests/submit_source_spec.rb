describe 'Quelle einreichen' do
  specify 'Formular ist abgeschaltet' do
    get '/quelle_einreichen'
    expect(response).to have_http_status(:gone)
    post '/quelle_einreichen', params: { submit_source: { url: 'http://spam.example' } }
    expect(response).to have_http_status(:gone)
  end
end
