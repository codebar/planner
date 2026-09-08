*Faster admin workshop pages*

A quick word of thanks to the organisers who have been putting up with the slow workshop pages, especially *London* and *Brighton* (and other chapters too).

The workshop detail page (`/admin/workshops/:id`) could take *~15 s* to load on the busiest workshops. It now loads in *~1.5 s* in production — around *10× faster*.

Two changes helped:
• *Fewer database queries* — the page was issuing 200+ queries (several per attendee); it now issues a handful.
• *A new "RSVP a member" page* — the old dropdown listed thousands of invitations. It's been replaced with a searchable page where you find a member by name and toggle their RSVP status in a single click. Look for the "RSVP a member" button on a workshop page.

No action needed from you — this is already live. The next time you open a workshop, it should feel noticeably quicker.
