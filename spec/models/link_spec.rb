require 'rails_helper'

RSpec.describe Link, type: :model do
  context 'Unique name specs' do
    let(:link) {Link.create!(url: 'goodprogrammer.ru')}

    it 'fails gracefully after 5 attempts' do
      allow(Link).to receive(:random_token).and_return('very_random_string')
      link

      bad_link = Link.create(url: 'goodprogrammer.ru')
      expect(bad_link.name).to be_nil
      expect(bad_link).not_to be_persisted
      expect(bad_link.errors).to include(:name)
    end

    it 'generates 3 symbol :name on create if Link.coun < 501' do
      expect(link.name).to match(/\A\w{3}\Z/)
    end

    it 'generates 4 symbol :name on create if Link.coun > 500' do
      allow(Link).to receive_message_chain(:where, :exists?).and_return(false)
      allow(Link).to receive_message_chain(:where, :count).and_return(501)

      expect(link.name).to match(/\A\w{4}\Z/)
    end

    it 'generates 7 symbol :name on create if Link.coun > 400_000' do
      allow(Link).to receive_message_chain(:where, :exists?).and_return(false)
      allow(Link).to receive_message_chain(:where, :count).and_return(400_001)

      expect(link.name).to match(/\A\w{7}\Z/)
    end

    it 'doesnt regenerates :name on update' do
      link.name = nil
      expect(link.valid?).to be_falsey
      expect(link.save).to be_falsey
      link.name = '1_1'
      expect(link.save).to be_truthy
    end

    it 'Auto adds http:// to :url' do
      expect(link.url).to eq 'http://goodprogrammer.ru'
      link.url = 'www.ya.ru/s=goodprogrammer'
      expect(link.save).to be_truthy
      expect(link.url).to eq 'http://www.ya.ru/s=goodprogrammer'
    end

    subject {Link.new(name: 'A123', url: 'ya.ru', domain: nil)}
    it {should validate_uniqueness_of(:name).scoped_to(:domain)}
  end

  # short name main checks, see https://github.com/thoughtbot/shoulda-matchers
  it {should_not allow_value('users').for(:name)}
  it {should allow_value('users_23').for(:name)}
  it {should_not allow_value('M-v0').for(:name)}
  it {should_not allow_value('M/v0').for(:name)}
  it {should allow_value('M_v0').for(:name)}

  # URL main checks
  it {should_not allow_value('/users/1').for(:url)}
  it {should_not allow_value('/ya.ru/').for(:url)}
  it {should_not allow_value('ht:ya.ru/').for(:url)}
  it {should_not allow_value('http:ya.ru/').for(:url)}
  it {should allow_value('http//ya.ru/').for(:url)}
  it {should allow_value('www.ya.ru/users/1?q=1').for(:url)}
  it {should allow_value('ya.ru/users/1?q=1').for(:url)}
  it {should allow_value('ya.ru').for(:url)}
  it {should allow_value('https://ya.ru').for(:url)}

  # Domain checks
  it {should_not allow_value('/users/1').for(:domain)}
  it {should_not allow_value('example.com/?stuff=true').for(:domain)}
  it {should_not allow_value('sub.domain.my-example.com/path/to/file/hello.html').for(:domain)}
  it {should allow_value('sub.example.com').for(:domain)}
  it {should allow_value('l.goodprogrammer.ru').for(:domain)}
  it {should allow_value('GOODPROGRAMMER.ru').for(:domain)}

  it {should belong_to(:user)}
end
