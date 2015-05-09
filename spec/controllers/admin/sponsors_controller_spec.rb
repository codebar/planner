require 'spec_helper'

describe Admin::SponsorsController, type: :controller do
  let(:member) { Fabricate(:member) }
  let(:address) { Fabricate(:address)}
  let(:admin) { Fabricate(:chapter_organiser) }
  let(:avatar) { Faker::Avatar.image }

  describe "POST #create" do
    it "Doesn't allow anonymous users to create sponsors" do
      expect {
        post :create, sponsor: { 
          name: 'name', email: 'test@test.com', contact_first_name: 'john',
          contact_surname: 'smith', website: 'https://example.com', seats: 40, 
          address: address, avatar: avatar 
        }
      }.to change(Sponsor, :count).by(0)
    end

    it "Doesn't allow regular users to create sponsors" do
      login member

      expect {
        post :create, sponsor: { 
          name: 'name', email: 'test@test.com', contact_first_name: 'john',
          contact_surname: 'smith', website: 'https://example.com', seats: 40, 
          address: address, avatar: avatar 
        }
      }.to change(Sponsor, :count).by(0)
    end

    it "Allows chapter organisers to create sponsors" do
      login admin
      request.env["HTTP_REFERER"] = "/admin/member/3"

      expect {
        post :create, sponsor: { 
          name: 'name', email: 'test@test.com', contact_first_name: 'john',
          contact_surname: 'smith', website: 'https://example.com', seats: 40, 
          address: address, avatar: avatar 
        }
      }.to change(Sponsor, :count).by(1)
    end

    it "Doesn't allow blank sponsors to be created" do
      expect {
        post :create, sponsor: { 
          name: '', email: 'test@test.com', contact_first_name: 'john',
          contact_surname: 'smith', website: 'https://example.com', seats: 40, 
          address: address, avatar: avatar 
        }
      }.to change(Sponsor, :count).by(0)
    end
  end
end