require 'spec_helper'

describe Admin::SponsorsController, type: :controller do
  let(:member) { Fabricate(:member) }
  let(:member1) { Fabricate(:member) }
  let(:address) { Fabricate(:address)}
  let(:admin) { Fabricate(:chapter_organiser) }
  let(:avatar) { Rails.root.join('spec/support/images/pug1.png') }
  let(:sponsor) { Fabricate(:sponsor)}

  describe "POST #create" do
    context("When not logged in") {
      it "Doesn't allow the user to create a sponsor" do
        expect {
          post :create, sponsor: { 
            name: 'name', email: 'test@test.com', contact_first_name: 'john',
            contact_surname: 'smith', website: 'https://example.com', seats: 40, 
            address: address, avatar: fixture_file_upload(avatar, 'image/png'), members: [1,2]
          }
        }.to change(Sponsor, :count).by(0)
      end
    }

    context("When logged in as a regular user") {
      before(:each) {
        login member
      }

      it "Doesn't allow the user to create a sponsor" do
        expect {
          post :create, sponsor: { 
            name: 'name', email: 'test@test.com', contact_first_name: 'john',
            contact_surname: 'smith', website: 'https://example.com', seats: 40, 
            address: address, avatar: fixture_file_upload(avatar, 'image/png') 
          }
        }.to change(Sponsor, :count).by(0)
      end
    }

    context "When logged in as admin" do
      before(:each) {
        login admin
      }

      it "Allows the user to create a sponsor with only contact info" do
        request.env["HTTP_REFERER"] = "/admin/member/3"

        expect {
          post :create, sponsor: { 
            name: 'name', email: 'test@test.com', contact_first_name: 'john',
            contact_surname: 'smith', website: 'https://example.com', seats: 40, 
            address: address, avatar: fixture_file_upload(avatar, 'image/png')
          }
        }.to change(Sponsor, :count).by(1)
      end

      it "Allows the user to create a sponsor with members as contacts and contact info" do
        request.env["HTTP_REFERER"] = "/admin/member/3"

        expect {
          post :create, sponsor: { 
            name: 'name', email: 'test@test.com', contact_first_name: 'john',
            contact_surname: 'smith', website: 'https://example.com', seats: 40, 
            address: address, avatar: fixture_file_upload(avatar, 'image/png'), contact_ids: [member.id, member1.id]
          }
        }.to change(Sponsor, :count).by(1)
      end

      it "Allows the user to create a sponsor with only members as contacts" do
        request.env["HTTP_REFERER"] = "/admin/member/3"

        expect {
          post :create, sponsor: { 
            name: 'name', website: 'https://example.com', seats: 40, 
            address: address, avatar: fixture_file_upload(avatar, 'image/png'), contact_ids: [member.id, member1.id]
          }
        }.to change(Sponsor, :count).by(1)
      end
      
      it "Allows the user to create a sponsor with latitude and longitude for its address" do
        request.env["HTTP_REFERER"] = "/admin/member/3"

        expect {
          post :create, sponsor: { 
            name: 'name', email: 'test@test.com', contact_first_name: 'john',
            contact_surname: 'smith', website: 'https://example.com', seats: 40, 
            address: Fabricate(:address, latitude: "54.47474", longitude: "-0.12345"), 
            avatar: fixture_file_upload(avatar, 'image/png'), members: []
          }
        }.to change(Sponsor, :count).by(1)
      end

      it "Doesn't allow the user to create a blank sponsor" do
        expect {
          post :create, sponsor: { 
            name: '', email: '', contact_first_name: '',
            contact_surname: '', website: '', seats: '', 
            address: '', avatar: '', members: []
          }
        }.to change(Sponsor, :count).by(0)
      end
    end
  end

  describe "POST #update" do
    context 'When not logged in' do
      it "Doesn't allow the user to update a sponsor" do
        post :update, id: sponsor.id, sponsor: { 
          contact_first_name: 'new_name',
          contact_surname: 'new_surname'
        }
        expect(sponsor.reload.contact_first_name).to eq sponsor.contact_first_name
      end
    end

    context 'When logged in as a regular user' do
      before(:each) {
        login member
      }

      it "Doesn't allow the user to update a sponsor" do
        post :update, id: sponsor.id, sponsor: { 
          contact_first_name: 'new_name',
          contact_surname: 'new_surname'
        }
        expect(sponsor.reload.contact_first_name).to eq sponsor.contact_first_name
      end
    end

    context "When logged in as admin" do
      before(:each) {
        login admin
      }

      it "Allows the user to update a sponsor with only contact info" do
        request.env["HTTP_REFERER"] = "/admin/member/3"

        post :update, id: sponsor.id, sponsor: { 
          contact_first_name: 'new_name',
          contact_surname: 'new_surname'
        }
        expect(sponsor.reload.contact_first_name).to eq sponsor.contact_first_name
      end

      it "Allows the user to update a sponsor with members as contacts and contact info" do
        request.env["HTTP_REFERER"] = "/admin/member/3"

        post :update, id: sponsor.id, sponsor: { 
          name: 'name', email: 'test@test.com', contact_first_name: 'new_first_name',
          contact_surname: 'smith', website: 'https://example.com', seats: 40, 
          address: address, avatar: fixture_file_upload(avatar, 'image/png'), contact_ids: [member.id, member1.id]
        }
        expect(sponsor.reload.contacts.count).to eq 2
        expect(sponsor.reload.contact_first_name).to eq 'new_first_name'
      end

      it "Allows the user to update a sponsor with only members as contacts" do
        request.env["HTTP_REFERER"] = "/admin/member/3"

        post :update, id: sponsor.id, sponsor: { 
          contact_ids: [member.id, member1.id]
        }
        expect(sponsor.reload.contacts.count).to eq 2
      end

      it "Allows the user to indicate that the venue is not accessible" do
        request.env["HTTP_REFERER"] = "/admin/member/3"

        post :update, id: sponsor.id, sponsor: { 
          address_attributes: { accessible: '0', note: 'No lift' }
        }

        expect(sponsor.reload.address.accessible).to be false
        expect(sponsor.reload.address.note).to eq 'No lift'
      end

      it "Allows the user to indicate that the venue is accessible" do
        request.env["HTTP_REFERER"] = "/admin/member/3"

        post :update, id: sponsor.id, sponsor: { 
          address_attributes: { accessible: '1' }
        }

        expect(sponsor.reload.address.accessible).to be true
      end
    end
  end
end