# Data model guide

This is a map of how the various tables in the data model fit
together. The headings here are ruby class names.

> Caveat lector: there are probably ways in which this document is
> wrong. Please update it if you find one. It is intended to serve as
> a guide, not a specification.

## Member

A `member` represents a single person who uses the site. It is also
sometimes referred to as a `user`. Members can be students, coaches,
both, or neither.

### AuthService

An `auth_service` is a service name and uid on that service. At
present, the service in production is always github, and the uid is
some unique identifier that github returns. This is used for
authentication: we find the `auth_service` for the uid that we get
from github oauth, and use that to find the `member` who is signed in.

### Permission

A `permission` is a single kind of access that can be granted. These
are managed by the Rolify gem. The permissions that are expected to
exist are:

* One global `admin` permission
* One `organiser` permission for each `chapter`
* One `organiser` permission for each `workshop`

The `members_permissions` table stores the users which have been
granted permissions. There is no ActiveRecord class for this table, it
is only accessed via the `Permission` class and Rolify.

## Chapter

A `chapter` represents a local organisation. It primarily serves to
collate things by location and organisers.

## Sponsor

A `sponsor` represents a location and organisation. Sponsors have a
student limit in the `seats` column, and may either have a fixed coach
limit in `number_of_coaches` or calculate this based on the student
limit.

### Address

Each `sponsor` may have one `address` describing their location.

### MemberContact

Some `members` may be designated as contacts for a sponsor. The
relationship between them is described by a `member_contact`, and
exposed as `Sponsor#contacts`.

## Workshop

A workshop corresponds to the `WorkshopsController` and `WorkshopPresenter`.

It belongs to a single `chapter`. It has organisers stored
as permissions.

Workshops work by sending invitations to the people
subscribed to their chapter, and will let those people accept the
invitation up to the limits of the `venue`. If no spaces are left,
people will instead be invited to join the waiting list, and will be
accepted from the waiting list as spaces become available.

### WorkshopSponsor

A `workshop_sponsor` describes which sponsors are sponsoring a given
workshop. There should be exactly one such object where the `host`
column is true, and zero or more where the `host` column is false. In
other parts of the code, the one with `host` set to true will be
referred to as the `venue`.

### WorkshopInvitation

A `workshop_invitation` describes a member's attendance status at a
`workshop`. An invitation relates a single `workshop`, a single
`member`, and a role that is either `"Student"` or `"Coach"`.

The `attending` field is true if the member has been assigned a place
to attend this workshop, and false if they have not been assigned a
place.

This object is created when an invitation is emailed to the member,
and its existence inhibits sending further emails.

### WaitingList

A `waiting_list` describes a member's desire to attend at a `workshop`,
should a place become available for them. It is associated directly to
a `workshop_invitation`, and to a workshop through that object.

If this object exists with the `auto_rsvp` field set to true then the
member is on the waiting list.

If this object exists with the `auto_rsvp` field set to false then the
member is not on the waiting list, but has asked to be reminded about
the workshop later.

If the member has been assigned a place to attend this workshop then
this object should not exist.

## Event

An `event` can be associated with many `chapters`. It has organisers
stored as permissions.

Events work by sending invitations to all the people subscribed to
their chapters, and letting those people indicate a desire to
attend. Admins can then verify/approve the attendees manually.

An event has a sponsor reference stored in the `venue` column, which
identifies the location where the event will happen.

### Sponsorship

A `sponsorship` identifies an additional sponsor for an event, other
than the location.

### Invitation

An `invitation` describes a member's attendance status at an
`event`. An invitation relates a single `workshop`, a single `member`,
and a role that is either `"Student"` or `"Coach"`.

The `attending` field is true if the member has indicated that they
want to attend. The `verified` field is true if an admin has marked
them as verified.

This object is created when an invitation is emailed to the member,
and its existence inhibits sending further emails.
