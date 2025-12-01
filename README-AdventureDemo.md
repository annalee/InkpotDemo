# Inkpot Adventure Demo

## Intro

The Adventure Demo provides design patterns and an example of how to use Ink and Inkpot to manage narrative text for a Narrative Adventure game in Unreal Engine.

It covers design patterns for implementing:
- Dialogue
- Player Journal
- Quests

### Audience

#### Journeyist Game Developers
You don't need to be an expert in either Ink or Unreal to understand this demo and documentation--it was created to be accessible to the advanced beginner. But it is not a full walkthrough for every step of the Ink/Inkpot/Unreal toolchain.

This demo and documentation assume:

- You have a working knowledge of the [Ink narrative scripting language]()
- You know how to navigate Unreal Engine's interface
- You have basic familiarity with Unreal's Blueprints
- You've read the [Inkpot Demo Readme]() and checked out the Demo level.

#### _Adventure_ Game Developers
This demo is focused on design patterns for games in which the player's place in the Ink story will be controlled by _Unreal_, not Ink: most typically, games in which the player can move themselves around the world and trigger narrative content by interacting with characters and objects they encounter.

Parts of these patterns may be useful for more traditional text adventures or visual novels, but when using Ink for a game like that, you can rely much more heavily on Ink's tools for managing the narrative flow.

### Non-Goals

The Adventure Demo is:

#### Not a definitive guide to Ink/Inkpot design patterns
This demo lays out _one_ way to use Ink and Inkpot to manage narrative text in Unreal, and serves as a practical guide for how to use Ink and Inkpot for game elements. It is far from the _only_ way.

Ink, Inkpot, and Unreal Engine are powerful tools, and there are many ways to use them to accomplish your goals.

#### Not a game framework
While you are free to copy, use, and modify the code included in this demo, it's not a plug-and-play solution that will allow you to start implementing your narrative adventure game in Unreal with minimal setup.

In order to keep the focus on design patterns for narrative text using Ink and Inkpot, the Adventure Demo doesn't include features like saving/loading/pausing, managing cameras for NPC conversations, or handling game mechanics such as combat, quicktime events, minigames, and puzzles. The UI widgets also use pretty basic styling (which is a nice way of saying they're ugly).

## CHECKPOINT
BEFORE YOU PROCEED: Now's a great time to load the Adventure Demo level and play it. The rest of this guide will be referencing the Adventure Demo level and explaining how it works.

## Design philosophy
These design patterns were heavily influenced by Inkle Narrative Director Jon Ingold's GDC talk [Narrative Sorcery: Cohesive Storytelling in an Open World](https://www.youtube.com/watch?v=HZft_U4Fc-U). If you're interested in diving deeper on narrative design for open world games, it's well worth your time.

But for the purposes of this demo, the principles we're building on are as follows:

### Narrative text belongs in Ink
Ink exists to keep narrative design and game writing separate from other parts of the game development workflow, so that writers can concentrate on writing without needing to deal with the full game engine.

This is helpful if you're on a team where the narrative designer is a different person from the programmers doing the game scripting--but it's also very nice if you're a solo game developer who wants to do one job at a time.

Wherever possible, avoid spreading narrative text across systems. Ink's greatest advantage is that it can help you flexibly and gracefully change the narrative based on the player's game state--the more of the narrative you keep in Ink, the easier that is to manage.

### Narrative flow belongs in Unreal
If you look in AdventureDemo.ink, you'll see `-> DONE` diverts at the close of almost every knot and stitch. This makes the demo impossible to play through in Inky: there's no logic to control where the player is going next.

In a visual novel or a text adventure in Ink, we direct the narrative flow using conditional logic, choices, and diverts to send players to where we want them to be and control what they do when they get there. For example, if the surly guard in front of the locked door refuses to open the door until the player brings her some plot coupons, the player will not be given a choice to walk through until the plot coupons have been duly presented.

By contrast, in an adventure game in Unreal, players control their own movement--and if there's somewhere we don't want them to go, we have to _take the option away_. What prevents the character from walking past the guard isn't the lack of a narrative choice to proceed--it's the collision settings on the door's mesh.

Because of this difference, we're relying on logic in Unreal--not Ink--to determine which knots and stitches to present to the player. While a character's path through a knot or stitch is controlled in Ink, the knots themselves are separate addresses we use to pull the right content, rather than sections of a linear flow.

### You don't know where the player has been
While most games gate a player's progression to some extent (often using literal gates with plot coupon collecting guards outside of them), games that let the player move around typically give them some choices about where they go and what they can do when they get there.

When a well-designed game gives the player agency to move around and explore, it will respect that agency by gracefully handling cases where the player doesn't follow the signposts.

For example, the demo level opens by telling the player "go talk to the Silver pawn." But what happens if you don't? What happens if you go explore the other elements of the world instead?

Knots (and to a lesser extent, stitches--more on that below) should be written without assumptions about where players have been and what they've done before reaching it. If a particular route is _possible_, it should be supported.

## Design Basics

### LISTs as state machines
Use of LISTs in Ink to track progress through the narrative are covered in [the Advanced State Tracking section of the Ink Docs](https://github.com/inkle/ink/blob/master/Documentation/WritingWithInk.md#part-5-advanced-state-tracking), and in Jon Ingold's [Narrative Sorcery GDC Talk](https://www.youtube.com/watch?v=HZft_U4Fc-U).

The short version:

The best way to avoid assumptions about the route a player has taken through the narrative is to track the state of storylines using LISTs. This is more elegant than relying on Ink's visit counts, as it allows the game to track states that a player can reach in different ways without a brittle and opaque tangle of queries.

(The even shorter version: `wolfquest ? KnowsOfWolf` is easier to maintain and read than `butcher.wolftalk || baker.wolftalk || candlestick_maker.sister_eaten`).

### Interactions are knots and stitches
A player will typically encounter narrative text in the game by tripping some kind of trigger event, such as:
- `BeginPlay`,
- `BeginOverlap` with a trigger volume
- Hitting the key or button to pull up their journal
- walking up to a character or object and pressing the key or button indicated by the floating interaction prompt.

This design pattern connects each individual trigger event in the game world to a knot or stitch--typically via a `SwitchFlowToPath` node.

TODO: image

When one of these events happens in the game, Unreal will use the knot or stitch to pull the correct content.

#### Knot or Stitch?
In the demo, we are using both knots and stitches as interaction paths.

Interacting with the shapes directs the flow to the `Quests.Findshapes_quest` stitch to pull the appropriate quest text.

In contrast, overlapping Emmy or Blue's trigger volumes directs the flow to their respective knots.

Which option to use comes down to how complex the associated narrative text is.

For this demo, we are using knots for each NPC and directing the flow to the appropriate stitch within the knot in Ink, using the player's LIST states. NPC conversations can be complex, and even a simple demo like this hangs multiple conversations off the same NPC interaction points.

For quests and journal entries, we're using stitches within the `Quest` and `Journal` knots, respectively. Quest stitches use a simple switching statement (again based on LIST states) to serve the correct line of quest text. Journal entries are longer, but fairly linear, and are easy to store in a stitch.

## Design Patterns

Here's a more in-depth guide to the design patterns for our three types of narrative text in the demo:

### Dialogue
The Dialogue pattern in this demo is using trigger volumes to initiate dialogue for each NPC, and each NPC has their own knot in the `AdventureDemo.ink`: `NPC_Emmy` and `NPC_Blue`.

TODO: screenshot

**Inkpot Concept: Flows**
> Flows allow Inkpot to keep track of multiple threads within the story--such as multiple NPC conversations--so that players can move between sections of the narrative without losing their place.
>
> For example: a character could go back and forth between two conversations.
>
> In this example, however, we're relying on switching logic within each NPC's knot in Ink to pull the appropriate conversation. To make this work, we've set restart to `true` on the `Switch Flow To Path` node, so that the player will be directed to the top of the NPC's knot (where this switching logic lives) every time they interact with the NPC.

The logic to update the UI with each line of dialogue and handle player choices lives in `WBP_Display_Adventure`.

**Inkpot Concept: Reading from tags**
> Inkpot contains nodes to read tags from Ink and use them within Unreal Blueprints. We have an example of this in the `Linetime: ` tags in AdventureDemo.ink.
>
> Inkpot lines can differ in length, which means they take different amounts of time to read.
>
> To handle this, there's logic in `WBP_Display_Adventure` to pull in the `Linetime` tag from Ink (Using the `Get Tag with Prefix and Strip` function, which, when given the prefix `Linetime: `, turn `Linetime: 2.5` to `2.5`) and pass the value into the `Set Timer by Event` node that times how long to show each line.
>
> TODO: screenshot
>
> (The `max` node returns the _maximum_ of its two inputs, so the linetime will always be set to the longer of 1.5 seconds, or the time specified by the Line Tag. This default ensures that the line time won't be set to 0 if the tag is missing).

### Player Journal

In the Ink file, Journal entries each have their own stitch in the "Journal" knot, which contains the journal entries (stored in stitches) and the menu/table of contents (in a sticky choice block).

The logic is pretty simple:
- A list of journal entries serves as a state machine to control which entries the player can see.
- The `JournalBookmark` variable stores a divert target to the current active entry.
- A sticky choice block serves as the table of contents/menu for the journal.
- The `<-JournalBookmark` line pulls the text of the active journal entry into the main knot, where it will be pulled--along with the journal menu--into the Journal panel in Unreal Engine.

Adding a new Journal entry to the Ink file has three steps:

#### Add it to the list

Pick a descriptive name for your entry. For an entry about getting the time for Emmy, we'll call it EmmyTime. Add it to the `JournalEntries` LIST at the top of the Journal knot.

This list will be used to determine which entries a player has access to during the story. 

#### Create the entry

Create a stitch within the Journal knot.

For the EmmytTime entry, we'll name it EmmyTime_entry.

Note: you need to differentiate the stitch name from the list item or the Ink interpreter will throw an error. You can technically name it anything you want, but it's easiest to stay organized if you use the descriptive name from the list and pick a consistent format to make the stitch name different from the list item. This demo ends each stitch name in `_entry`.)

Add the text of your entry to this stitch, and end with a DONE divert.

**Formatting note**: For demo purposes, the function ToTextFormat in WBP_Display_Adventure has a hard-coded Replace node to turn `<br>` into an additional newline, to make these entries easier to read. In your game, you'll almost certainly want to use a Rich Text box instead of MultiLine Text, and create a formatting style to double-space between paragraphs.

#### Add it to the journal menu

In the Journal knot itself, above the entry stitches, there's a block of Journal entry choices. This is the menu/table of contents.

Each journal entry should be added to the menu as a sticky choice within the choice block. The choice should be gated behind a condition that checks if the player has access to the entry, and the choice text should be a human-readable name for the entry.

Inside the choice, all you need to do is:

1. Set the `JournalBookmark` variable to a divert target to the stitch you created.
2. Divert back to the main Journal knot.

Like so:

```
+ {JournalEntries has EmmyTime} [Quest: Give Emmy the time]
    ~ JournalBookmark = -> EmmyTime_entry
    -> Journal
```

`JournalBookmark` sets the active Journal entry, which the Journal knot will thread in.

#### Unreal Logic

**Inkpot Concept: Flows aren't simultaneous**
> [The Inkpot Demo Readme]() notes that flows allow us to run threads of the story "run at the same time," but it's important to note that Inkpot does not currently allow players to be in two flows _simultaneously_. Instead, Inkpot saves the player's place in each flow, and when they return to that flow, they pick up where they left off.
>
> The Journal implementation takes advantage of this to manage what happens when the player closes the journal. When the player opens the Journal panel, they switch into the Journal flow. When they close it, they return to the flow they were in previously and pick up where they left off.

If you look at the Blueprint graph in `WBP_Display_Adventure`, you'll see the logic for the journal in two sections:

The "Show/hide journal panel" section handles the logic to switch between the journal panel (where this text is displayed) and the Main Story panel (where you'll see dialogue and quest text).

TODO: screenshot

That way, a player can open their journal when there's other ink text showing for them to read--and when they close their journal, it'll drop them in their previous flow.

The "Update JournalEntry view with selected entry" section handles the logic for switching between journal entries when the player selects something from the list.

TODO: screenshot

The UpdateJournalView function populates the JournalEntryList panel with the entries the player can select.

TODO: screenshot

**Inkpot Concept: Story Change Delegate**
> When the player gets access to new journal entries, a notification will pop up in the UI.
>
> This is triggered within `WBP_Display_Adventure`, using a Story Change Delegate:
>
> TODO: screenshot
>
> This allows game logic in Unreal (in this case, the Widget Blueprint) to get notified when an Ink variable changes, and kick off a custom event.

### Quests

#### Ink setup

Quests in this demo are making heavy use of LISTs as state machines to track the player's progress.

We're again using flow-switching to know when to display quest text. Text for each quest is stored in its own stitch in the Quests knot. Switching logic within the stitch will show the appropriate text depending on the player's progress.

#### Unreal setup

At the moment, there's no Unreal-specific setup to do for quest text--it will be handled by the same Blueprint logic being used for dialogue.

That's because there's no dedicated UI surface for Quest Text in this demo. Since it's not possible for the game to be in two flows at the same time, we can't display quest text and dialogue simultaneously--so they share a UI panel.

(The journal also can't be displayed simultaneously, but since the Journal UI panel hides the main story panel, switching the flow to the journal and back is seamless for the player. It wouldn't make sense to interrupt dialogue to show quest updates).

The upshot is that you'll need to think about when to trigger quest text to make sure it's not interrupting dialogue.

In the demo, we're triggering quest text when the player interacts with the shapes, and when the player leaves an NPC trigger volume and returns to the default flow. This makes sure it won't collide with dialogue.