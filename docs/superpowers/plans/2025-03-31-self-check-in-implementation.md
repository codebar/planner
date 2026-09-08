# Self Check-In Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let event/workshop attendees mark themselves as attended by scanning a QR code. Organisers download a landscape PDF displayed at the venue entrance.

**Architecture:** New `check_in_code` column on events/workshops (3-word EFF code). New `source` column on invitation tables. A `CheckInPdf` service generates landscape PDFs. Two new controllers: `Admin::CheckInsController` (instructions + PDF download) and public `CheckInsController` (auth + role selection + check-in). QR encodes a short URL resolved by `check_in_code`.

**Tech Stack:** Rails 8.1, PostgreSQL, HAML, Prawn (PDF), RQRCode (QR), EFF large word list

## Global Constraints

- Every new code path that creates an invitation must set `source` explicitly
- `source` column is nullable — NULL = legacy records, no backfill
- `check_in_code` generated on `before_create` for new records; lazy generation on first PDF download for existing records
- QR encodes the full absolute URL (use `_url` helpers, not `_path`)
- Admin check-in controller uses `respond_to` for HTML (instructions) and PDF (download)
- Public check-in controller polymorphic — handles both events and workshops
- No rake task for backfill; codes generated lazily

---
### Task 1: Database migration

**Files:**
- Create: `db/migrate/YYYYMMDDHHMMSS_add_check_in_code_to_events.rb`
- Create: `db/migrate/YYYYMMDDHHMMSS_add_check_in_code_to_workshops.rb`
- Create: `db/migrate/YYYYMMDDHHMMSS_add_source_to_invitations.rb`
- Create: `db/migrate/YYYYMMDDHHMMSS_add_source_to_workshop_invitations.rb`

**Interfaces:**
- Produces: `events.check_in_code` (string, unique, indexed), `workshops.check_in_code` (string, unique, indexed), `invitations.source` (string, nullable), `workshop_invitations.source` (string, nullable)

- [ ] **Step 1: Add `check_in_code` to events**

```ruby
class AddCheckInCodeToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :check_in_code, :string
    add_index :events, :check_in_code, unique: true
  end
end
```

- [ ] **Step 2: Add `check_in_code` to workshops**

```ruby
class AddCheckInCodeToWorkshops < ActiveRecord::Migration[8.1]
  def change
    add_column :workshops, :check_in_code, :string
    add_index :workshops, :check_in_code, unique: true
  end
end
```

- [ ] **Step 3: Add `source` to invitations**

```ruby
class AddSourceToInvitations < ActiveRecord::Migration[8.1]
  def change
    add_column :invitations, :source, :string
  end
end
```

- [ ] **Step 4: Add `source` to workshop_invitations**

```ruby
class AddSourceToWorkshopInvitations < ActiveRecord::Migration[8.1]
  def change
    add_column :workshop_invitations, :source, :string
  end
end
```

- [ ] **Step 5: Run migrations**

```bash
bundle exec rails db:migrate
```

- [ ] **Step 6: Commit**

```bash
git add db/migrate/
git commit -m "feat: add check_in_code and source columns for self check-in"
```

---
### Task 2: Word list + model concern for check_in_code generation

**Files:**
- Create: `lib/words/check_in_words.txt`
- Create: `app/models/concerns/check_in_code.rb`
- Modify: `app/models/event.rb`
- Modify: `app/models/workshop.rb`

**Interfaces:**
- Consumes: `events.check_in_code` column, `workshops.check_in_code` column
- Produces: `CheckInCode` concern with `generate_check_in_code!` and `check_in_url` methods, included in Event and Workshop

- [ ] **Step 1: Download and bundle EFF word list**

```bash
curl -sL "https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt" \
  | awk '{print $2}' > lib/words/check_in_words.txt
```

Verify line count:
```bash
wc -l lib/words/check_in_words.txt
# Expected: 7776
```

- [ ] **Step 2: Write the CheckInCode concern**

Key details:
- Word list loaded lazily (memoized class method) to avoid 7776-line read on every class reload in dev
- `set_check_in_code` runs in `before_create`
- `generate_check_in_code!` is for lazy generation on existing records
- `check_in_url` builds the full URL for the QR

```ruby
# app/models/concerns/check_in_code.rb
module CheckInCode
  extend ActiveSupport::Concern

  WORD_LIST_PATH = Rails.root.join("lib", "words", "check_in_words.txt")

  class_methods do
    def word_list
      @word_list ||= File.readlines(WORD_LIST_PATH).map(&:strip).freeze
    end
  end

  included do
    before_create :set_check_in_code
  end

  def generate_check_in_code!
    loop do
      code = self.class.word_list.sample(3).join("-")
      unless self.class.exists?(check_in_code: code)
        update_column(:check_in_code, code)
        return code
      end
    end
  end

  def check_in_url
    prefix = model_name.singular == "event" ? "e" : "w"
    route_name = :"check_in_#{prefix}_url"
    Rails.application.routes.url_helpers.public_send(
      route_name, check_in_code
    )
  end

  private

  def set_check_in_code
    loop do
      self.check_in_code = self.class.word_list.sample(3).join("-")
      break unless self.class.exists?(check_in_code: check_in_code)
    end
  end
end
```

Note: `check_in_url` relies on `default_url_options[:host]` being configured. Verify `config/environments/development.rb` and `production.rb` have `config.action_mailer.default_url_options` set (they should already for existing email functionality).

- [ ] **Step 3: Include concern in Event**

```ruby
# app/models/event.rb — add alongside other includes
include CheckInCode
```

- [ ] **Step 4: Include concern in Workshop**

```ruby
# app/models/workshop.rb — add alongside other includes
include CheckInCode
```

- [ ] **Step 5: Write model tests**

In `spec/models/event_spec.rb`:
```ruby
describe "check_in_code" do
  it "generates a check_in_code on create" do
    event = create(:event)
    expect(event.check_in_code).to be_present
    expect(event.check_in_code.split("-").length).to eq(3)
  end

  it "generates a unique check_in_code" do
    codes = 3.times.map { create(:event).check_in_code }
    expect(codes.uniq.length).to eq(3)
  end
end
```

Same pattern in `spec/models/workshop_spec.rb`.

- [ ] **Step 6: Run tests**

```bash
bundle exec rspec spec/models/event_spec.rb spec/models/workshop_spec.rb
```

- [ ] **Step 7: Commit**

```bash
git add lib/words/check_in_words.txt app/models/concerns/check_in_code.rb app/models/event.rb app/models/workshop.rb
git commit -m "feat: add check_in_code generation from EFF word list"
```

---
### Task 3: Add gems + CheckInPdf service

**Files:**
- Modify: `Gemfile`
- Create: `app/services/check_in_pdf.rb`

**Interfaces:**
- Consumes: Event or Workshop with `check_in_code` and `check_in_url` methods
- Produces: `CheckInPdf#render` returning PDF binary string

- [ ] **Step 1: Add gems**

```ruby
# Gemfile — add alongside other gems
gem "rqrcode"
gem "prawn"
```

- [ ] **Step 2: Bundle install**

```bash
bundle install
```

- [ ] **Step 3: Write the CheckInPdf service**

Landscape A4 layout: header → event info → venue → sponsors → QR code centered.

```ruby
# app/services/check_in_pdf.rb

class CheckInPdf
  def initialize(parent)
    @parent = parent
  end

  def render
    Prawn::Document.new(page_layout: :landscape, page_size: "A4", margin: 20) do |pdf|
      # Header
      pdf.text "codebar", size: 16, color: "333333"
      pdf.move_down 8

      # Event info
      pdf.text @parent.to_s, size: 28, style: :bold
      pdf.move_down 4
      pdf.text formatted_date, size: 16, color: "555555"
      pdf.move_down 8

      # Venue
      if @parent.respond_to?(:venue) && @parent.venue.present?
        venue = @parent.venue
        pdf.text venue.name, size: 14, color: "555555"
        if venue.respond_to?(:address) && venue.address.present?
          pdf.text venue.address.to_s, size: 12, color: "777777"
        end
        pdf.move_down 4
      end

      # Sponsors
      if @parent.respond_to?(:sponsors) && @parent.sponsors.any?
        pdf.text "Sponsored by: #{@parent.sponsors.map(&:name).join(', ')}", size: 12, color: "777777"
        pdf.move_down 8
      end

      # QR code — centered
      qrcode = RQRCode::QRCode.new(@parent.check_in_url)
      png = qrcode.as_png(module_size: 6)
      qr_width = 160

      pdf.bounding_box([(pdf.bounds.width - qr_width) / 2.0, pdf.cursor],
                       width: qr_width, height: pdf.cursor - 20) do
        pdf.image StringIO.new(png.to_blob), width: qr_width, position: :center
        pdf.move_down 4
        pdf.text "Scan to check in", size: 11, align: :center, color: "999999"
        pdf.move_down 2
        pdf.text @parent.check_in_url.sub(%r{^https?://}, ""),
                 size: 10, align: :center, color: "999999"
      end
    end.render
  end

  private

  def formatted_date
    dt = @parent.date_and_time
    dt.strftime("%A, %B %d, %Y at %H:%M")
  end
end
```

- [ ] **Step 4: Write service test**

```ruby
# spec/services/check_in_pdf_spec.rb
require "rails_helper"

RSpec.describe CheckInPdf do
  let(:event) { create(:event, check_in_code: "sunny-ocean-breeze") }

  subject { described_class.new(event) }

  it "generates a PDF" do
    pdf = subject.render
    expect(pdf).to start_with("%PDF")
  end

  it "includes the check-in URL in the PDF" do
    pdf = subject.render
    expect(pdf).to include(event.check_in_url)
  end
end
```

- [ ] **Step 5: Run tests**

```bash
bundle exec rspec spec/services/check_in_pdf_spec.rb
```

- [ ] **Step 6: Commit**

```bash
git add Gemfile Gemfile.lock app/services/check_in_pdf.rb spec/services/check_in_pdf_spec.rb
git commit -m "feat: add CheckInPdf service for landscape QR check-in PDF"
```

---
### Task 4: Admin::CheckInsController + instructions page

**Files:**
- Create: `app/controllers/admin/check_ins_controller.rb`
- Create: `app/views/admin/check_ins/show.html.haml`
- Modify: `config/routes.rb` (add admin check-in routes)

**Interfaces:**
- Consumes: Event/Workshop with `check_in_code`, `generate_check_in_code!`, `check_in_url`, `CheckInPdf`
- Produces: HTML instructions page and PDF download via `respond_to`

- [ ] **Step 1: Write the controller**

```ruby
# app/controllers/admin/check_ins_controller.rb
class Admin::CheckInsController < Admin::ApplicationController
  before_action :load_parent

  def show
    authorize @parent
    @parent.generate_check_in_code! if @parent.check_in_code.blank?

    respond_to do |format|
      format.html
      format.pdf do
        pdf = CheckInPdf.new(@parent).render
        send_data pdf,
                  filename: "check-in-#{@parent.to_param}.pdf",
                  type: "application/pdf",
                  disposition: "attachment"
      end
    end
  end

  private

  def load_parent
    if params[:event_id]
      @parent = Event.find_by!(slug: params[:event_id])
    elsif params[:workshop_id]
      @parent = Workshop.find(params[:workshop_id])
    end
  end
end
```

- [ ] **Step 2: Write the instructions view**

```haml
-# app/views/admin/check_ins/show.html.haml

%h2 Check-in for #{@parent.to_s}

.alert.alert-info
  %p.mb-0
    Let attendees mark themselves as attended by scanning the QR code on the PDF.
    Once scanned, they sign in with GitHub and confirm their role.
    You'll see their attendance update in the event admin page.

.card.mb-4
  .card-body
    %h5.card-title Check-in URL
    %p.lead.mb-1= @parent.check_in_code
    %p.text-muted.small= @parent.check_in_url
    %p.text-muted.small Share this URL with anyone who can't scan the QR code.

.card.mb-4
  .card-body
    %h5.card-title How to use
    %ol
      %li Download the PDF below.
      %li Print it or display it on a screen at the venue entrance.
      %li Attendees scan the QR code with their phone.
      %li They sign in with GitHub and select their role (Student/Coach).
      %li They're checked in! You can see attendance on the event/workshop admin page.

= link_to admin_event_check_in_path(@parent, format: :pdf),
          class: 'btn btn-primary btn-lg' do
  %i.fas.fa-download
  Download PDF
```

- [ ] **Step 3: Add admin routes**

Inside `namespace :admin` block in `config/routes.rb`:

```ruby
resources :events, only: [] do
  resource :check_in, only: [:show], controller: "check_ins"
end

resources :workshops, only: [] do
  resource :check_in, only: [:show], controller: "check_ins"
end
```

Singular `resource` since there's one check-in per event/workshop. Helpers: `admin_event_check_in_path(@event)`, `admin_workshop_check_in_path(@workshop)`.

- [ ] **Step 4: Write controller test**

```ruby
# spec/controllers/admin/check_ins_controller_spec.rb
require "rails_helper"

RSpec.describe Admin::CheckInsController do
  let(:admin) { create(:member, :admin) }
  let(:event) { create(:event) }

  before { sign_in admin }

  describe "GET show" do
    it "renders the instructions page" do
      get :show, params: { event_id: event.slug }
      expect(response).to be_successful
    end

    it "generates check_in_code if missing" do
      expect { get :show, params: { event_id: event.slug } }
        .to change { event.reload.check_in_code }.from(nil)
    end

    it "returns PDF for .pdf format" do
      get :show, params: { event_id: event.slug, format: :pdf }
      expect(response.content_type).to eq("application/pdf")
    end
  end
end
```

- [ ] **Step 5: Run tests**

```bash
bundle exec rspec spec/controllers/admin/check_ins_controller_spec.rb
```

- [ ] **Step 6: Commit**

```bash
git add app/controllers/admin/check_ins_controller.rb \
       app/views/admin/check_ins/show.html.haml \
       config/routes.rb \
       spec/controllers/admin/check_ins_controller_spec.rb
git commit -m "feat: add admin check-in controller with instructions and PDF download"
```

---
### Task 5: Admin toolbar buttons

**Files:**
- Modify: `app/views/admin/events/show.html.haml`
- Modify: `app/views/admin/workshops/show.html.haml`

**Interfaces:**
- Consumes: Admin event/workshop show page toolbar
- Produces: "Check-in" button in toolbar linking to instructions page

- [ ] **Step 1: Add button to events show page**

In `app/views/admin/events/show.html.haml`, add to the `.container-fluid.btn-group.p-0` toolbar:

```haml
= link_to admin_event_check_in_path(@original_event), class: 'btn btn-primary py-3' do
  %i.fas.fa-qrcode
  %label.text-white Check-in
```

Note: Events show page uses `@original_event` for non-presenter model instance. Verify this variable exists and points to the right model.

- [ ] **Step 2: Add button to workshops show page**

In `app/views/admin/workshops/show.html.haml`:

```haml
= link_to admin_workshop_check_in_path(@workshop), class: 'btn btn-primary py-3' do
  %i.fas.fa-qrcode
  %label.text-white Check-in
```

- [ ] **Step 3: Commit**

```bash
git add app/views/admin/events/show.html.haml app/views/admin/workshops/show.html.haml
git commit -m "feat: add Check-in button to admin event/workshop toolbar"
```

---
### Task 6: Public CheckInsController (check-in flow)

**Files:**
- Create: `app/controllers/check_ins_controller.rb`
- Create: `app/views/check_ins/new.html.haml`
- Create: `app/views/check_ins/confirm.html.haml`
- Modify: `config/routes.rb` (add public check-in routes)

**Interfaces:**
- Consumes: Event/Workshop with `check_in_code`, `check_in_url`, invitation models with `source`
- Produces: Role-selection page, confirmation page, invitation records with `source: "check_in"`

- [ ] **Step 1: Write the controller**

Key design:
- Don't override `authenticate_member!` — set `session[:referer_path]` before it runs
- `load_parent` tries both Event and Workshop by `check_in_code` (collision probability negligible)
- Already-checked-in handled inline in view, not a separate render
- Helper methods for form/redirect URLs, polymorphic between e/w routes

```ruby
# app/controllers/check_ins_controller.rb
class CheckInsController < ApplicationController
  before_action :load_parent
  before_action :store_referer_path, only: [:new]
  before_action :authenticate_member!, only: [:new]

  def new
    @invitation = find_invitation
    @suggested_role = infer_role
    @already_checked_in = already_checked_in?(@invitation)
  end

  def create
    role = params[:role]
    invitation = find_or_create_invitation(role)
    mark_attended(invitation)
    redirect_to check_in_confirm_path
  end

  def confirm
    @invitation = find_invitation
  end

  private

  def load_parent
    @parent = Event.find_by(check_in_code: params[:code]) ||
              Workshop.find_by(check_in_code: params[:code])
    raise ActiveRecord::RecordNotFound unless @parent
  end


  helper_method :check_in_submit_path, :check_in_confirm_path

  def check_in_submit_path
    @parent.is_a?(Event) ?
      check_in_e_path(code: @parent.check_in_code) :
      check_in_w_path(code: @parent.check_in_code)
  end

  def check_in_confirm_path
    @parent.is_a?(Event) ?
      check_in_e_confirm_path(code: @parent.check_in_code) :
      check_in_w_confirm_path(code: @parent.check_in_code)
  end

  def store_referer_path
    session[:referer_path] = request.path unless logged_in?
  end

  def already_checked_in?(invitation)
    return false unless invitation

    if @parent.is_a?(Event)
      invitation.verified?
    else
      invitation.attended?
    end
  end

  def find_invitation
    if @parent.is_a?(Event)
      Invitation.find_by(event: @parent, member: current_user)
    else
      WorkshopInvitation.find_by(workshop: @parent, member: current_user)
    end
  end

  def find_or_create_invitation(role)
    if @parent.is_a?(Event)
      Invitation.find_or_create_by!(event: @parent, member: current_user, role: role)
    else
      WorkshopInvitation.find_or_create_by!(workshop: @parent, member: current_user, role: role)
    end
  end

  def mark_attended(invitation)
    attrs = { attending: true, source: "check_in" }
    if @parent.is_a?(Event)
      attrs[:verified] = true
    else
      attrs[:attended] = true
    end
    invitation.update!(attrs)
  end

  def infer_role
    return @invitation.role if @invitation.present?

    groups = current_user.groups
    student = groups.students.any?
    coach = groups.coaches.any?

    if student && !coach
      "Student"
    elsif coach && !student
      "Coach"
    else
      nil
    end
  end
end
```

- [ ] **Step 2: Write the role-selection view**

Handles both first-visit and already-checked-in states:

```haml
-# app/views/check_ins/new.html.haml

%h1= @parent.to_s
%p.lead= l(@parent.date_and_time, format: :long)

- if @already_checked_in
  .text-center.py-4
    %h2.text-success ✓ Already checked in!
    %p.lead As a #{@invitation.role}
    = link_to "Back to Dashboard", dashboard_path, class: "btn btn-primary mt-3"
- else
  %h3 Welcome, #{current_user.name}!

  - if @invitation.present?
    %p You were invited as a #{@invitation.role}. Confirm below.

  - if @suggested_role
    %p.text-muted We think you're here as a #{@suggested_role}.

  .row.mt-4
    .col-6
      = form_tag check_in_submit_path, method: :post do
        = hidden_field_tag :role, "Student"
        = submit_tag "I'm a Student",
          class: "btn btn-lg btn-block #{"btn-primary" if @suggested_role == "Student"} #{"btn-outline-secondary" unless @suggested_role == "Student"}",
          style: "width: 100%; min-height: 80px; font-size: 1.5rem;"

    .col-6
      = form_tag check_in_submit_path, method: :post do
        = hidden_field_tag :role, "Coach"
        = submit_tag "I'm a Coach",
          class: "btn btn-lg btn-block #{"btn-primary" if @suggested_role == "Coach"} #{"btn-outline-secondary" unless @suggested_role == "Coach"}",
          style: "width: 100%; min-height: 80px; font-size: 1.5rem;"
```

- [ ] **Step 3: Write the confirmation view**

```haml
-# app/views/check_ins/confirm.html.haml

.text-center.py-5
  %h1.text-success ✓ You're checked in!
  %p.lead As a #{@invitation.role} at #{@parent.to_s}
  %p.text-muted= l(@parent.date_and_time, format: :long)
  = link_to "Back to Dashboard", dashboard_path, class: "btn btn-primary mt-4"
```

- [ ] **Step 4: Add public check-in routes**

At the top level of `config/routes.rb` (outside any namespace). All use `:code` as the param name:

```ruby
get  "check-in/e/:code" => "check_ins#new", as: :check_in_e
post "check-in/e/:code" => "check_ins#create"
get  "check-in/e/:code/confirm" => "check_ins#confirm", as: :check_in_e_confirm
get  "check-in/w/:code" => "check_ins#new", as: :check_in_w
post "check-in/w/:code" => "check_ins#create"
get  "check-in/w/:code/confirm" => "check_ins#confirm", as: :check_in_w_confirm
```

- [ ] **Step 5: Write controller tests**

Uses request specs (not controller specs) since the polymorphic `load_parent` relies on request path to determine type. Or use `params` only since `load_parent` tries both lookups:

```ruby
# spec/controllers/check_ins_controller_spec.rb
require "rails_helper"

RSpec.describe CheckInsController do
  let(:member) { create(:member) }
  let(:event) { create(:event, check_in_code: "test-code-abc") }

  before { sign_in member }

  describe "GET new" do
    it "renders the role selection page" do
      get :new, params: { code: event.check_in_code }
      expect(response).to be_successful
    end

    it "redirects to auth if not logged in" do
      sign_out member
      get :new, params: { code: event.check_in_code }
      expect(response).to redirect_to("/auth/github")
    end
  end

  describe "POST create" do
    it "creates an invitation with source=check_in" do
      post :create, params: { code: event.check_in_code, role: "Student" }
      invitation = Invitation.last
      expect(invitation.source).to eq("check_in")
      expect(invitation.attending).to be true
      expect(invitation.verified).to be true
    end
  end
end
```

- [ ] **Step 6: Run tests**

```bash
bundle exec rspec spec/controllers/check_ins_controller_spec.rb
```

- [ ] **Step 7: Commit**

```bash
git add app/controllers/check_ins_controller.rb \
       app/views/check_ins/ \
       config/routes.rb \
       spec/controllers/check_ins_controller_spec.rb
git commit -m "feat: add public check-in flow with role selection and confirmation"
```

---
### Task 7: Update existing code paths to set `source`

**Files:**
- Modify: `app/services/invitation_manager.rb`
- Modify: `app/controllers/admin/invitations_controller.rb`
- Modify: `app/controllers/admin/invitation_controller.rb`
- Modify: `app/controllers/events_controller.rb`
- Modify: `app/controllers/workshops_controller.rb`

**Interfaces:**
- Consumes: Invitation and WorkshopInvitation models with `source` column
- Produces: All invitation-creation paths set `source` explicitly

- [ ] **Step 1: Update InvitationManager**

`app/services/invitation_manager.rb`:

```ruby
# invite_students_to_event — add source:
Invitation.new(event: event, member: student, role: 'Student', source: "email")

# invite_coaches_to_event — add source:
Invitation.new(event: event, member: coach, role: 'Coach', source: "email")

# create_invitation — add source to find_or_initialize_by:
invitation = WorkshopInvitation.find_or_initialize_by(
  workshop: workshop, member: member, role: role, source: "email"
)
```

- [ ] **Step 2: Update Admin::InvitationsController**

`app/controllers/admin/invitations_controller.rb`, in `update_to_attending`:

```ruby
def update_to_attending
  update_successful = @invitation.update(
    attending: true,
    rsvp_time: Time.zone.now,
    automated_rsvp: true,
    last_overridden_by_id: current_user.id,
    source: "admin"
  )
```

- [ ] **Step 3: Update Admin::InvitationController (event verification)**

`app/controllers/admin/invitation_controller.rb`:

```ruby
# In update:
invitation.update(attending: true, verified: true, verified_by: current_user, source: "admin")

# In verify:
invitation.update(verified: true, verified_by_id: current_user.id, source: "admin")
```

- [ ] **Step 4: Update EventsController**

`app/controllers/events_controller.rb`:

```ruby
# rsvp action:
Invitation.create(event: @event, member: member, role: 'Student', source: "email")

# find_invitation_and_redirect_to_event:
Invitation.find_or_create_by(event: @event, member: current_user, role: role, source: "email")
```

- [ ] **Step 5: Update WorkshopsController**

`app/controllers/workshops_controller.rb`:

```ruby
# find_or_create_invitation:
WorkshopInvitation.find_or_create_by(
  workshop: workshop, member: user, role: role, source: "email"
)
```

- [ ] **Step 6: Run existing tests to verify no regressions**

```bash
bundle exec rspec spec/controllers/admin/invitations_controller_spec.rb \
  spec/controllers/admin/invitation_controller_spec.rb \
  spec/services/invitation_manager_spec.rb \
  spec/controllers/events_controller_spec.rb \
  spec/controllers/workshops_controller_spec.rb
```

- [ ] **Step 7: Commit**

```bash
git add app/services/invitation_manager.rb \
       app/controllers/admin/invitations_controller.rb \
       app/controllers/admin/invitation_controller.rb \
       app/controllers/events_controller.rb \
       app/controllers/workshops_controller.rb
git commit -m "feat: set source column in all invitation-creation code paths"
```

---
### Task 8: Final integration check

**Files:**
- No file changes — verification only

- [ ] **Step 1: Run full test suite**

```bash
bundle exec parallel_rspec spec/ -n 3
```

Verify all tests pass. Investigate and fix any failures.

- [ ] **Step 2: Manual smoke test — admin flow**

```bash
bundle exec rails server
```

1. Log in as admin
2. Navigate to an existing event admin page
3. Verify "Check-in" button appears in toolbar
4. Click to open instructions page
5. Verify check_in_code is displayed
6. Click "Download PDF"
7. Verify PDF downloads

- [ ] **Step 3: Manual smoke test — public check-in flow**

1. Open a private/incognito window
2. Navigate to `/check-in/e/<code>` (from step 2)
3. Verify redirect to GitHub auth
4. Sign in with GitHub
5. Verify role-selection page renders
6. Select a role
7. Verify confirmation page shows "You're checked in!"
8. Verify invitation record exists with `source: "check_in"`

- [ ] **Step 4: Commit if any fixes made**

```bash
git commit -m "fix: post-integration adjustments"
```
