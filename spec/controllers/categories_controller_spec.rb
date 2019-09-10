describe CategoriesController do
  render_views

  specify '#index' do
    get :index
    expect(response).to be_successful
    expect(response.body).to include "Alle Kategorien auf"
  end

  specify '#show' do
    c = Fabricate(:category)
    get :show, params: { id: c.slug }
    expect(response).to be_successful
    expect(response.body).to include "Alle News zum Thema #{c.name}"
  end
end
