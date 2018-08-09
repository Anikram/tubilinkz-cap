require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) {User.create!(email: 'test@test.ru', password: '123456')}
  let(:valid_link_attributes) {{'url' => 'l.goodprogrammer.ru'}}

  before(:each) {sign_in user}

  describe 'GET #show' do
    it 'users right template' do
      get :show, params: {id: user.to_param}
      expect(response).to have_http_status(:success)
      expect(response).to render_template('users/show')
    end

    it 'assigns right links for user' do
      link1 = Link.create!(valid_link_attributes)
      link2 = Link.create!(valid_link_attributes.merge(user: user))

      get :show, params: {id: user.to_param}
      expect(assigns(:total_links_count)).to eq(1)
      expect(assigns(:recent_links)).to contain_exactly(link2)
    end
  end
end
