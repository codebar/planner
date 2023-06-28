require 'spec_helper'

RSpec.describe Admin::SponsorsController, type: :controller do
  let(:member) { Fabricate(:member) }
  let(:member1) { Fabricate(:member) }
  let(:address) { Fabricate(:address) }
  let(:admin) { Fabricate(:chapter_organiser) }
  let(:avatar) { Rack::Test::UploadedFile.new(Rails.root.join('app', 'assets', 'images', 'logo.png'), 'image/png') }
  let(:sponsor) { Fabricate(:sponsor) }

  describe 'POST #create' do
    it "Doesn't allow anonymous users to create sponsors" do
      expect do
        post :create, sponsor: {
          name: 'name', website: 'https://example.com', seats: 40,
          address: address, avatar: avatar, members: [1, 2]
        }
      end.to change(Sponsor, :count).by(0)
    end

    it "Doesn't allow regular users to create sponsors" do
      login member

      expect do
        post :create, sponsor: {
          name: 'name', website: 'https://example.com', seats: 40,
          address: address, avatar: avatar
        }
      end.to change(Sponsor, :count).by(0)
    end

    context 'Allows chapter organisers to create sponsors with' do
      it 'only contact info' do
        login admin
        request.env['HTTP_REFERER'] = '/admin/member/3'

        expect do
          post :create, sponsor: {
            name: 'name', website: 'https://example.com', seats: 40, number_of_coaches: 1,  
            address: address, avatar: avatar
          }
        end.to change(Sponsor, :count).by(1)
      end

      it 'members as contacts and contact info' do
        login admin
        request.env['HTTP_REFERER'] = '/admin/member/3'

        expect do
          post :create, sponsor: {
            name: 'name', website: 'https://example.com', seats: 40, number_of_coaches: 1,
            address: address, avatar: avatar, contact_ids: [member.id, member1.id]
          }
        end.to change(Sponsor, :count).by(1)
      end

      it 'only members as contacts' do
        login admin
        request.env['HTTP_REFERER'] = '/admin/member/3'

        expect do
          post :create, sponsor: {
            name: 'name', website: 'https://example.com', seats: 40, number_of_coaches: 1,
            address: address, avatar: avatar, contact_ids: [member.id, member1.id]
          }
        end.to change(Sponsor, :count).by(1)
      end

      it 'latitude and longitude for its address' do
        login admin
        request.env['HTTP_REFERER'] = '/admin/member/3'

        expect do
          post :create, sponsor: {
            name: 'name', website: 'https://example.com', seats: 40, number_of_coaches: 1,
            address: Fabricate(:address, latitude: '54.47474', longitude: '-0.12345'),
            avatar: avatar, members: []
          }
        end.to change(Sponsor, :count).by(1)
      end
    end

    it "Doesn't allow blank sponsors to be created" do
      expect do
        post :create, sponsor: {
          name: '', website: '', seats: '',
          address: '', avatar: '', members: []
        }
      end.to change(Sponsor, :count).by(0)
    end
  end

  describe 'POST #update' do
    it "Doesn't allow anonymous users to update sponsors" do
      post :update, id: sponsor.id, sponsor: {
        name: 'new name'
      }
      expect(sponsor.reload.name).to eq sponsor.name
    end

    it "Doesn't allow regular users to update sponsors" do
      login member

      post :update, id: sponsor.id, sponsor: {
        name: 'new_name'
      }
      expect(sponsor.reload.name).to eq sponsor.name
    end

    context 'Allows chapter organisers to update sponsors with' do
      it 'only contact info' do
        login admin
        request.env['HTTP_REFERER'] = '/admin/member/3'

        post :update, id: sponsor.id, sponsor: {
          name: 'new_name'
        }
        expect(sponsor.reload.name).to eq sponsor.name
      end
    end
  end
end
