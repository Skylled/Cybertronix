# What is Cybertronix?

Cybertronix is a specialized job management software built with Flutter and Firebase,
for my dad's company.

# Who is it for?

For now, the end product is really only for those in the fire protection industry.
The source code could be useful though, for someone learning the Flutter framework.

# What does it do?

## Agenda

This page pulls a list of jobs from Firebase, sorted by `datetime`, ending at two weeks
from the current date. Then it generates an expanding tile for each day in the next two
weeks and sorts the jobs into those days.

Each tile is headed by its job count, so that at a glance it can be known if a given day
has any jobs scheduled, and how many.

## Browser

This is a landing page for all the categories of data that might want to be browsed
through.

## Category

This is a list of all items in a subcategory, sorted by name. A floating action button is available to add a new object to the list.

#### To-Do
- [ ] Enable search, or change sorting method.

## Selector dialog

Just like the category list, this dialog displays a list of objects in a subcategory, sorted by name, and returns a selection to its caller.

## Category card

This is the detailed view for a given object, displaying the information as best suited. This view is generally displayed within a dialog.
#### To-Do
- [ ] Enable images, adding to/loading from Firebase Storage

## Creator Card

Creator Cards are dialogs for the creation of new objects. For the most part, I adapted code from Flutter's [Expansion Panels Demo](https://github.com/flutter/flutter/blob/ae8994860e42c3eff67149282e93be47c07f9f93/examples/flutter_gallery/lib/demo/material/expansion_panels_demo.dart). A better way is probably possible.

# FAQ
## Why does the app crash on startup?

You need to include `google-services.json` from Firebase to run this app in any capacity.
Maybe soon I'll spin up a demo Firebase instance and sync it here for demonstration.

For an idea of how the database is structured, take a look at `Firebase Structure.json`

## Why are you doing things the weird/hard way?

Probably because I don't know any better. This is my first Dartlang project, and my first
Flutter project. Feel free to ask questions. I'd love to discuss and get feedback on my
beginner methods.

## Are you the guy in `hey-ladies.jpg`?

**No**, that's my friend.
