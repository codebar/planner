# Email Assets

Images in this folder are used in transactional emails sent by the planner
application. They are referenced via the Rails asset pipeline with digest
fingerprinting.

## ⚠️ Do not modify or delete existing files

The digest fingerprint is derived from the file content. Changing an image
here changes its URL. Any previously-sent email that references the old URL
will show a broken image in the recipient's inbox.

**Additive changes only.** Need a new image for a new email? Add a new file.
Need a new logo? Add it as a new filename (e.g. `logo-2026.png`) and update
the mailer view to reference the new file. Never mutate an existing file.

## Email stylesheet

The email CSS lives at `app/assets/stylesheets/email.css` — not in this
folder. It's linked from mailer layouts via the pipeline path `email.css`,
and `premailer-rails` inlines the rules at delivery time using the
`:filesystem` and `:asset_pipeline` strategies (see
`config/initializers/premailer.rb`).

⚠️ Never add a `<link>` that resolves at open time — premailer handles
inlining, and external CSS requests are unreliable in email clients.
