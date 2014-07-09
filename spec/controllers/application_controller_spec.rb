require 'spec_helper'

describe ApplicationController do
  describe '#set_locale' do
    after(:each) do
      I18n.locale = I18n.default_locale
    end

    it 'gets from user.language' do
      controller.stub_chain(:current_user, :language).and_return :de
      expect(controller.send :set_locale).to eq :de
    end

    it 'gets from session (for annonymous user)' do
      controller.stub(:session).and_return({:language => :ch})
      expect(controller.send :set_locale).to eq :ch
    end

    it 'gets from http header' do
      controller.stub(:extract_from_header).and_return :'pt-BR'
      expect(controller.send :set_locale).to eq :'pt-BR'
    end

    it 'defaults to I18n.default_locale' do
      controller.stub(:extract_from_header).and_return nil
      expect(controller.send :set_locale).to_not be_nil
      expect(controller.send :set_locale).to eq I18n.default_locale
    end
  end

  describe "#language" do
    before { controller.request.env['HTTP_REFERER'] = "http://test.host/" }

    context "invalid code" do
      before { get :language, :code => code }

      shared_examples_for 'do not set language and redirect back' do
        it { expect(controller.session[:language]).to be_nil }
        it { expect(response).to redirect_to :back }
      end

      context 'nil' do
        let(:code) { '' }
        it_behaves_like 'do not set language and redirect back'
      end

      context 'unavailable code' do
        let(:code) { 'ch' }
        it_behaves_like 'do not set language and redirect back'
      end
    end

    context 'valid code' do
      let(:code) { 'pt-BR' }
      after { controller.session[:language] = nil }

      context 'annonymous user' do
        before { get :language, :code => code }
        it { expect(controller.session[:language]).to eq code }
      end

      context 'logged user' do
        let(:user) { FactoryGirl.create(:user) }

        before do
          login_user user
          get :language, :code => code
        end

        it "saves the language to the user" do
          expect(controller.current_user).to be_a_kind_of User
          expect(user.reload.language).to eq code
          expect(controller.session[:language]).to eq code
        end
      end
    end
  end

  describe '#to_bool' do
    it 'gets true from string' do
      expect(controller.send :to_bool, 'true').to be true
      expect(controller.send :to_bool, 't').to be true
      expect(controller.send :to_bool, 'yes').to be true
      expect(controller.send :to_bool, 'y').to be true
      expect(controller.send :to_bool, '1').to be true
    end

    it 'gets false from string' do
      expect(controller.send :to_bool, 'false').to be false
      expect(controller.send :to_bool, 'f').to be false
      expect(controller.send :to_bool, 'no').to be false
      expect(controller.send :to_bool, 'n').to be false
      expect(controller.send :to_bool, '0').to be false
    end

    it 'gets true from true' do
      expect(controller.send :to_bool, true).to be true
    end

    it 'gets false from false' do
      expect(controller.send :to_bool, false).to be false
    end

    it 'gets false from nil' do
      expect(controller.send :to_bool, nil).to be false
    end

    it 'raises exception from invalid string' do
      expect {controller.send :to_bool, 'spam'}.to raise_error(ArgumentError)
    end
  end

  describe "#cleaned_contacts" do
    context 'nil' do
      let(:params) { {contacts: nil} }
      it { expect(controller.send :cleaned_contacts, params).to eq({}) }
    end
    context 'valid hash' do
      let(:params) { {contacts: {address: 'Foo', phone: '12345', compl: ''}} }
      it { expect(controller.send :cleaned_contacts, params).to eq({address: 'Foo', phone: '12345'}) }
    end
  end

  describe "#cleaned_tags" do
    context 'default field name' do
      let(:params) { {tags: "foo,bar,baz"} }
      it { expect(controller.send :cleaned_tags, params).to eq ["foo", "bar", "baz"]}
    end
    context 'other field name' do
      let(:params) { {interests: "foo,bar,baz"} }
      it { expect(controller.send :cleaned_tags, params, :interests).to eq ["foo", "bar", "baz"]}
    end
    context 'nil' do
      let(:params) { {tags: nil} }
      it { expect(controller.send :cleaned_tags, params).to eq []}
    end
  end

end
