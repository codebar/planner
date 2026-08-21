# frozen_string_literal: true
# rubocop:disable all

# Temporary task to detect and merge members created as duplicates by the
# codebar auth GitHub sign-in flow (codebar/planner#2805).
#
# Usage:
#   Local dump:
#     make detect_duplicate_members
#     make fix_duplicate_members
#     make fix_duplicate_members APPLY=1
#
#   Production:
#     heroku run rake member:duplicates:detect --app codebar-production
#     heroku run rake member:duplicates:fix APPLY=1 --app codebar-production
#
# The task switches to the local dump when DB_NAME is set; otherwise it uses the
# current Rails environment's database (e.g. Heroku DATABASE_URL).

namespace :member do
  namespace :duplicates do
    desc 'Detect duplicate members created by the codebar auth flow'
    task detect: :environment do
      MergeDuplicateMembers.establish_connection!
      duplicates = MergeDuplicateMembers::Detector.new.call
      MergeDuplicateMembers::Reporter.new(duplicates).print
    end

    desc 'Merge duplicate members into their originals (set APPLY=1 to execute)'
    task fix: :environment do
      MergeDuplicateMembers.establish_connection!
      dry_run = ENV['APPLY'] != '1'
      duplicates = MergeDuplicateMembers::Detector.new.call

      if duplicates.empty?
        puts 'No duplicate members detected.'
        next
      end

      puts dry_run ? 'DRY RUN — no changes will be made.' : 'APPLYING merges...'
      puts

      logger = MergeDuplicateMembers::RunLogger.new(dry_run: dry_run)

      duplicates.each do |pair|
        begin
          MergeDuplicateMembers::Merger.new(pair, dry_run: dry_run).call
          logger.record_merge(dup_id: pair.dup_member_id, orig_id: pair.original_member_id, strategies: pair.merge_strategies, status: 'success')
        rescue StandardError => e
          logger.record_error(e)
          raise
        end
        puts
      end

      log_path = logger.flush
      puts dry_run ? "Run with APPLY=1 to execute these #{duplicates.size} merges." : 'Done.'
      puts "Log: #{log_path}" if log_path
    end

    desc 'Verify no duplicate members remain after merging'
    task verify: :environment do
      MergeDuplicateMembers.establish_connection!
      duplicates = MergeDuplicateMembers::Detector.new.call

      if duplicates.empty?
        puts 'PASS: no duplicate members detected.'
      else
        puts "FAIL: #{duplicates.size} duplicate member(s) still detected:"
        MergeDuplicateMembers::Reporter.new(duplicates).print
        exit 1
      end
    end
  end
end

module MergeDuplicateMembers
  # The merge of the /auth/codebar sign-in flow into planner.
  # Duplicates cannot have been created before this point.
  CUTOFF_TIME = Time.utc(2026, 8, 6, 15, 25, 11)

  # Email domains that are too generic for the domain-similarity heuristic.
  COMMON_DOMAINS = %w[
    gmail.com googlemail.com outlook.com hotmail.com live.com yahoo.com
    ymail.com icloud.com me.com mac.com aol.com qq.com 163.com 126.com
    foxmail.com protonmail.com proton.me
  ].freeze

  # Hard-coded merges for cases the heuristics cannot safely detect.
  # Format: [duplicate_member_id, original_member_id]
  MANUAL_OVERRIDES = [
    [31_257, 27_714] # Lou Alldis's third account
  ].freeze

  class << self
    def establish_connection!
      return unless ENV['DB_NAME'].present?

      ActiveRecord::Base.establish_connection(
        adapter: 'postgresql',
        host: ENV.fetch('DB_HOST', 'localhost'),
        port: ENV.fetch('DB_PORT', 5432),
        database: ENV.fetch('DB_NAME'),
        username: ENV.fetch('DB_USER', ''),
        password: ENV.fetch('POSTGRES_PASSWORD', '')
      )
    end

    def truncate(string, max_length)
      string.length > max_length ? "#{string[0...max_length - 1]}…" : string
    end
  end

  class Detector
    def call
      detected = (name_matches + email_matches + firstname_uid_surname_matches + domain_local_matches)
                 .group_by(&:dup_member_id)
                 .transform_values { |matches| best_match(matches) }

      apply_manual_overrides(detected)
      detected.values.reject { |m| already_merged?(m) }.sort_by { |m| -m.dup_member.id }
    end

    private

    def already_merged?(match)
      dup = match.dup_member
      dup.email.start_with?('duplicate.') ||
        !AuthService.exists?(member_id: dup.id, provider: 'codebar')
    end

    private

    def codebar_members
      Member.joins(:auth_services)
            .where(auth_services: { provider: 'codebar' })
            .where('members.created_at > ?', CUTOFF_TIME)
    end

    def name_matches
      codebar_members
        .joins(<<~SQL)
          JOIN members originals
            ON LOWER(TRIM(members.name)) = LOWER(TRIM(originals.name))
           AND LOWER(TRIM(members.surname)) = LOWER(TRIM(originals.surname))
           AND NULLIF(TRIM(members.name), '') IS NOT NULL
           AND NULLIF(TRIM(members.surname), '') IS NOT NULL
        SQL
        .joins("JOIN auth_services original_auth ON original_auth.member_id = originals.id AND original_auth.provider = 'github'")
        .where('originals.created_at < members.created_at')
        .select("members.id AS dup_member_id, originals.id AS original_member_id, 'name+surname' AS strategy")
        .map { |r| Match.new(r.dup_member_id, r.original_member_id, r.strategy) }
    end

    def email_matches
      codebar_members
        .joins('JOIN members originals ON LOWER(TRIM(members.email)) = LOWER(TRIM(originals.email)) AND originals.id != members.id')
        .joins("JOIN auth_services original_auth ON original_auth.member_id = originals.id AND original_auth.provider = 'github'")
        .where('originals.created_at < members.created_at')
        .select("members.id AS dup_member_id, originals.id AS original_member_id, 'email' AS strategy")
        .map { |r| Match.new(r.dup_member_id, r.original_member_id, r.strategy) }
    end

    def firstname_uid_surname_matches
      codebar_members
        .joins('JOIN members originals ON LOWER(TRIM(members.name)) = LOWER(TRIM(originals.name))')
        .joins("JOIN auth_services original_auth ON original_auth.member_id = originals.id AND original_auth.provider = 'github'")
        .where('NULLIF(TRIM(members.name), \'\') IS NOT NULL')
        .where("members.surname IS NULL OR TRIM(members.surname) = ''")
        .where('originals.created_at < members.created_at')
        .where("LOWER(auth_services.uid) LIKE '%' || LOWER(originals.surname) || '%'")
        .select("members.id AS dup_member_id, originals.id AS original_member_id, 'first-name+uid-surname' AS strategy")
        .map { |r| Match.new(r.dup_member_id, r.original_member_id, r.strategy) }
    end

    def domain_local_matches
      non_common_domains = COMMON_DOMAINS.map { |d| "'#{d}'" }.join(',')

      codebar_members
        .joins('JOIN members originals ON split_part(members.email, \'@\', 2) ILIKE split_part(originals.email, \'@\', 2)')
        .joins("JOIN auth_services original_auth ON original_auth.member_id = originals.id AND original_auth.provider = 'github'")
        .where('originals.id != members.id')
        .where('originals.created_at < members.created_at')
        .where(Arel.sql("split_part(members.email, '@', 2) NOT IN (#{non_common_domains})"))
        .where(<<~SQL)
          split_part(members.email, '@', 1) ILIKE '%' || split_part(originals.email, '@', 1) || '%'
          OR split_part(originals.email, '@', 1) ILIKE '%' || split_part(members.email, '@', 1) || '%'
        SQL
        .where(<<~SQL)
          (SELECT COUNT(*) FROM members_permissions mp WHERE mp.member_id = originals.id) > 0
          OR (SELECT COUNT(*) FROM members_roles mr WHERE mr.member_id = originals.id) > 0
          OR (SELECT COUNT(*) FROM subscriptions s WHERE s.member_id = originals.id) > 0
          OR (SELECT COUNT(*) FROM workshop_invitations wi WHERE wi.member_id = originals.id) > 0
        SQL
        .select("members.id AS dup_member_id, originals.id AS original_member_id, 'domain+local-part' AS strategy")
        .map { |r| Match.new(r.dup_member_id, r.original_member_id, r.strategy) }
    end

    def best_match(matches)
      matches.max_by do |m|
        orig = m.original_member
        [orig.roles.count, orig.subscriptions.count, orig.workshop_invitations.count]
      end
    end

    def apply_manual_overrides(detected)
      MANUAL_OVERRIDES.each do |dup_id, orig_id|
        next unless Member.exists?(dup_id) && Member.exists?(orig_id)

        detected[dup_id] = Match.new(dup_id, orig_id, 'manual')
      end
    end
  end

  class Match
    attr_reader :dup_member_id, :original_member_id, :strategies

    def initialize(dup_member_id, original_member_id, strategy)
      @dup_member_id = dup_member_id
      @original_member_id = original_member_id
      @strategies = Set[strategy]
    end

    def dup_member
      @dup_member ||= Member.find(@dup_member_id)
    end

    def original_member
      @original_member ||= Member.find(@original_member_id)
    end

    def merge_strategies
      @strategies.to_a.sort.join(', ')
    end
  end

  class Reporter
    def initialize(matches)
      @matches = matches
    end

    def print
      puts format('%-10s %-25s %-35s %-10s %-35s %-25s', 'Dup id', 'Dup name', 'Dup email', 'Orig id', 'Original email', 'Strategies')
      puts '-' * 150
      @matches.each do |m|
        dup = m.dup_member
        orig = m.original_member
        name = [dup.name, dup.surname].compact.join(' ')
        puts format('%-10s %-25s %-35s %-10s %-35s %-25s',
                    dup.id, MergeDuplicateMembers.truncate(name, 25), MergeDuplicateMembers.truncate(dup.email, 35),
                    orig.id, MergeDuplicateMembers.truncate(orig.email, 35), m.merge_strategies)
      end
    end
  end

  class RunLogger
    LOG_DIR = Rails.root.join('log', 'merge_duplicate_members').freeze

    def initialize(dry_run:)
      @dry_run = dry_run
      @started_at = Time.now.iso8601
      @merges = []
      @errors = []
    end

    def log_path
      @log_path ||= LOG_DIR.join("run_#{Time.now.utc.strftime('%Y%m%dT%H%M%SZ')}.json")
    end

    def record_merge(dup_id:, orig_id:, strategies:, status:)
      return if @dry_run

      @merges << { dup_id: dup_id, orig_id: orig_id, strategies: strategies, status: status }
    end

    def record_error(error)
      return if @dry_run

      @errors << { message: error.message, backtrace: error.backtrace.first(5) }
    end

    def flush
      return if @dry_run || (@merges.empty? && @errors.empty?)

      entry = {
        timestamp: @started_at,
        dry_run: @dry_run,
        environment: Rails.env,
        merges: @merges,
        errors: @errors,
        total_merges: @merges.size
      }

      FileUtils.mkdir_p(LOG_DIR)
      File.write(log_path, JSON.pretty_generate(entry))
      log_path
    end
  end

  class Merger
    def initialize(match, dry_run: true)
      @match = match
      @dry_run = dry_run
    end

    def call
      dup = @match.dup_member
      orig = @match.original_member

      puts "#{dry_run_label}Merging member #{dup.id} (#{dup.email}) into #{orig.id} (#{orig.email})"

      if already_merged?(dup, orig)
        puts '  Already merged; skipping.'
        return
      end

      within_transaction do
        move_auth_service(dup, orig)
        merge_subscriptions(dup, orig)
        merge_workshop_invitations(dup, orig)
        merge_invitations(dup, orig)
        merge_meeting_invitations(dup, orig)
        merge_member_notes(dup, orig)
        merge_bans(dup, orig)
        merge_eligibility_inquiries(dup, orig)
        merge_attendance_warnings(dup, orig)
        merge_member_email_deliveries(dup, orig)
        merge_testimonials(dup, orig)
        merge_feedback_requests(dup, orig)
        update_invitation_logs(dup, orig)
        deactivate_duplicate(dup, orig)
      end

      puts "  #{dry_run_label}Done."
    end

    private

    def dry_run_label
      @dry_run ? '[DRY RUN] ' : ''
    end

    def already_merged?(dup, orig)
      !Member.exists?(dup.id) ||
        dup.email.start_with?('duplicate.') ||
        (AuthService.exists?(member_id: orig.id, provider: 'codebar') &&
         !AuthService.exists?(member_id: dup.id, provider: 'codebar'))
    end

    def within_transaction
      if @dry_run
        ActiveRecord::Base.transaction do
          yield
          raise ActiveRecord::Rollback
        end
      else
        ActiveRecord::Base.transaction { yield }
      end
    end

    def move_auth_service(dup, orig)
      auth = AuthService.find_by(member_id: dup.id, provider: 'codebar')
      return unless auth

      puts "  #{dry_run_label}Moving codebar auth service (#{auth.uid}) to original"
      auth.update!(member_id: orig.id)
    end

    def merge_subscriptions(dup, orig)
      dup.subscriptions.find_each do |sub|
        if orig.subscriptions.exists?(group_id: sub.group_id)
          puts "  #{dry_run_label}Deleting duplicate subscription for group #{sub.group_id}"
          sub.destroy!
        else
          puts "  #{dry_run_label}Moving subscription for group #{sub.group_id}"
          sub.update!(member_id: orig.id)
        end
      end
    end

    def merge_workshop_invitations(dup, orig)
      dup.workshop_invitations.find_each do |wi|
        if orig.workshop_invitations.exists?(workshop_id: wi.workshop_id, role: wi.role)
          puts "  #{dry_run_label}Deleting duplicate workshop invitation #{wi.workshop_id}/#{wi.role}"
          wi.destroy!
        else
          puts "  #{dry_run_label}Moving workshop invitation #{wi.workshop_id}/#{wi.role}"
          wi.update!(member_id: orig.id)
        end
      end
    end

    def merge_invitations(dup, orig)
      dup.invitations.find_each do |inv|
        if orig.invitations.exists?(event_id: inv.event_id)
          puts "  #{dry_run_label}Deleting duplicate invitation for event #{inv.event_id}"
          inv.destroy!
        else
          puts "  #{dry_run_label}Moving invitation for event #{inv.event_id}"
          inv.update!(member_id: orig.id)
        end
      end
    end

    def merge_meeting_invitations(dup, orig)
      dup.meeting_invitations.find_each do |mi|
        if orig.meeting_invitations.exists?(meeting_id: mi.meeting_id)
          puts "  #{dry_run_label}Deleting duplicate meeting invitation #{mi.meeting_id}"
          mi.destroy!
        else
          puts "  #{dry_run_label}Moving meeting invitation #{mi.meeting_id}"
          mi.update!(member_id: orig.id)
        end
      end
    end



    def merge_member_notes(dup, orig)
      dup.member_notes.update_all(member_id: orig.id)
    end

    def merge_bans(dup, orig)
      dup.bans.update_all(member_id: orig.id)
    end

    def merge_eligibility_inquiries(dup, orig)
      dup.eligibility_inquiries.update_all(member_id: orig.id)
    end

    def merge_attendance_warnings(dup, orig)
      dup.attendance_warnings.update_all(member_id: orig.id)
    end

    def merge_member_email_deliveries(dup, orig)
      dup.member_email_deliveries.update_all(member_id: orig.id)
    end

    def merge_testimonials(dup, orig)
      return unless defined?(Testimonial)

      count = Testimonial.where(member_id: dup.id).update_all(member_id: orig.id)
      puts "  #{dry_run_label}Moved #{count} testimonial(s)" if count.positive?
    end

    def merge_feedback_requests(dup, orig)
      count = FeedbackRequest.where(member_id: dup.id).update_all(member_id: orig.id)
      puts "  #{dry_run_label}Moved #{count} feedback request(s)" if count.positive?
    end

    def update_invitation_logs(dup, orig)
      count = InvitationLog.where(initiator_id: dup.id).update_all(initiator_id: orig.id)
      puts "  #{dry_run_label}Updated #{count} invitation log initiator(s)" if count.positive?
    end

    def deactivate_duplicate(dup, orig)
      dup.auth_services.destroy_all
      dup.roles.clear

      new_email = "duplicate.#{dup.id}.merged-into.#{orig.id}@codebar.io"
      puts "  #{dry_run_label}Renaming duplicate email to #{new_email}"
      dup.update_columns(email: new_email)

      note = "Duplicate of member #{orig.id} (#{orig.email}). Merged #{Time.zone.now.iso8601}. Login disabled."
      dup.member_notes.create!(note: note, author_id: orig.id)
    end
  end
end

# rubocop:enable all
