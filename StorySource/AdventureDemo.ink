# Title: Inkpot Narative Adventure Demo

-> Main

/* This is the Ink file for the AdventureDemo level in the Inkpot Demo project.

It's designed to provide design patterns and examples of ways to implement common narrative adventure game functionality in Unreal Engine using Ink and Inkpot.

Checkout the AdventureDemoREADME for a walkthrough of how everything works.

The demo covers patterns for implementing:
    - Dialogue
    - Journal entries
    - Quests
*/

// FUNCTIONS - INK's BUILT-IN LIBRARY

=== function pop(ref _list) 
    ~ temp el = LIST_MIN(_list) 
    ~ _list -= el
    ~ return el 

=== function list_with_commas(list)
	{ list:
		{_list_with_commas(list, LIST_COUNT(list))}
	}

=== function _list_with_commas(list, n)
	{pop(list)}{ n > 1:{n == 2: and |, }{_list_with_commas(list, n-1)}}


// FUNCTIONS - Custom

// A !^ function that returns all items in list that are NOT in excluding.
=== function not_in(list, excluding)
    ~ temp disjoint = ()
    {excluding:
        ~ temp overlap = list ^ excluding
        ~ disjoint = LIST_INVERT(overlap) ^ list
    - else:
        ~ disjoint = list
    }
    
    ~ return disjoint

// STORY

VAR clocktime = ""

LIST Items = cone, cube, sphere, watch
    VAR InventoryItems = ()
    VAR shapes = (cone, cube, sphere)

=== Main ===

{!Welcome! This demo provides some examples for how to set up dialogue, quests, and a journal in InkPot.} # Linetime: 2.5

{
    - QuestMeetEmmy !? ToldEmmyJournal:
        -> Quests.MeetEmmy_quest
    - QuestGetTime !? ToldEmmyTime:
        -> Quests.GetTime_quest
    }
    
On to your next adventure.

-> DONE

=== NPC_Emmy ===
{
    - QuestGetTime ? ToldEmmyTime:
        -> thanks
    - QuestGetTime ? (EmmyAsked, GotAnswer):
        -> answer
    - QuestGetTime ? EmmyAsked:
        -> ask
    - QuestMeetEmmy ? OpenedJournal:
        -> timequest
    - QuestMeetEmmy ? MetEmmy:
        -> intro.EmmyGivesJournal
    }
-> intro

= intro
Hi, I'm Emmy. I have a TriggerVolume around me that you moved into. That triggered a "Switch Flow to Path" node that brought you into my NPC dialogue knot. # Linetime: 2.5

Check out the EventGraph in the Level Blueprint to see how it's organized.

~ QuestMeetEmmy += MetEmmy

- (EmmyGivesJournal)

This is an example of some DIALOGUE. I'll add an entry on DIALOGUE to your JOURNAL. Plus an entry on JOURNAL ENTRIES. # Linetime: 2

~ JournalEntries += (journal, dialogue)

(Woah, meta).

{
    - QuestMeetEmmy ? OpenedJournal:
        -> timequest
    -else:
        Check those out by clicking on your Journal in the top right, then come back. (You may need to back away and approach me again to start a new conversaton). # Linetime: 2.5
    }

-> DONE

= timequest
~ QuestMeetEmmy += ToldEmmyJournal
{Great, now let's try a quest. |}

Can you ask Blue what time it is?

* (YouDoIt)[Can't you go ask Blue?]

    Well aren't you a fancypants narrative designer, expecting NPCs to advance their own plots instead of just standing around waiting for a hero. # Linetime: 2.5
    
    Unfortunately I don't have a character movement component--or even my own Blueprint-- so no I cannot ask Blue. # Linetime: 2.5
    
    Now, as much as I'd love to stand around discussing Jon Ingold's GDC talk on using LISTS as state machines for encounters in SORCERY--I have things to teach you about quest mechanics. # Linetime: 3
    
    -> timequest
    
* {QuestGetTime !? GotAnswer and InventoryItems !? watch} [Sure.]
    Thanks! <>
* {QuestGetTime ? GotAnswer and InventoryItems !? watch} [Blue doesn't like me very much.]
    Oh cool so the game told you to come talk to me and you wandered around the map antagonizing other NPCs instead. # Linetime: 2.5
    
    Nice work. # Linetime: 3
    
    I don't have a face, but I hope you picked up that the 3-second linetime on "Nice work" represented me staring at you judgmentally. # Linetime: 2.5
    
    (There's logic in WBP_Display_Adventure to pull in a "Linetime" tag from Ink and use it to set the timer for how long to keep the line up). # Linetime: 2.5
    
    Anyway. That's you finished with the tutorial. <>
    ~ QuestGetTime += ToldEmmyTime
* {InventoryItems ? watch} [It's {clocktime}.]
    Doing the quests out of order, I see. I respect it.
    ~ QuestGetTime += ToldEmmyTime

- I'm adding an entry on quests to your JOURNAL. # Linetime: 2
~ QuestGetTime += EmmyAsked
~ JournalEntries += quests
~ JournalEntries += EmmyTime

-> DONE

= ask
Hello again!
-> DONE

= answer
Did you ask Blue the time?

* {InventoryItems ? watch} [The time is {clocktime}]
    Thanks!
* {InventoryItems !? watch} [She wouldn't say.]
    To you either? I should steal her watch.

-
~ QuestGetTime += ToldEmmyTime

-> DONE

= thanks
Thanks for doing this tutorial.

-> DONE

=== NPC_Blue ===

{
    - QuestGetTime ? GotAnswer:
        -> hi_again
    - QuestFindShapes ? GotShapes:
        -> telltime
    - QuestGetTime ? AskedTime:
        -> hi_again
    - QuestGetTime ? EmmyAsked:
        -> asktime
}

-> blueIntro

= blueIntro

Hi there--could you help me out? I'm trying to find my {list_with_commas(shapes)}. # Linetime: 2.5

-> shapesFetch

= asktime

Hi, I'm Blue.

* [Emmy wants to know the time.]
* [Do you have the time?]
-
~ QuestGetTime += AskedTime

Blue: Sorry, I'm busy looking for my {list_with_commas(shapes)}. If you find them for me, I'll tell you the time. # Linetime: 2

-> shapesFetch

= shapesFetch
~ QuestFindShapes += BlueAsked

* [Sure, I can get them for you.]
    Thanks!
* [Can't you get them?]
    {NPC_Emmy.timequest.YouDoIt: Yeah look I'm not a nerd like Emmy; I'm not going to wax philisophic about narrative design.} # Linetime: 2.5
    
    {QuestGetTime ? EmmyAsked: If you want to know the time, you'll need to get my shapes.|I can't get them myself--can you help me?} # Linetime: 2

- ~ JournalEntries += BlueShapes
-> DONE

= telltime
{QuestFindShapes ? BlueAsked: I see you've found them all|You found my missing shapes}! Thanks!

* [You're welcome.]
    Here, you can have my watch.
    ~InventoryItems += watch
* {QuestFindShapes ? BlueAsked}[They were literally right there.]
    If you're going to be rude, then {QuestGetTime ? EmmyAsked: it's time for you to get a watch|no quest reward for you}.
* {QuestFindShapes !? BlueAsked}[Finders Keepers.]
    Fine, no reward for you then.
   
-
~ QuestFindShapes += ToldBlue
~ QuestGetTime += GotAnswer
  
-> DONE

= hi_again
Hi again.

-> DONE

=== Quests ===
//Quest Trackers
/*  
    For a text adventure of this simplicity, we could rely on checking if knot/stitch labels evaluate true. (/Documentation/WritingWithInk.md#advanced-knotstitch-labels-are-actually-read-counts).

    But for interfacing with a game engine, it's simpler/cleaner to track quest state in a LIST so we can watch the quests variables for updates (for triggering UI etc) instead of having a soupy mess of stitch labels to monitor.
*/

LIST QuestMeetEmmy = MetEmmy, OpenedJournal, ToldEmmyJournal
LIST QuestGetTime = EmmyAsked, AskedTime, GotAnswer, ToldEmmyTime
LIST QuestFindShapes = BlueAsked, GotShapes, ToldBlue

-> DONE

= MeetEmmy_quest

{
    - QuestMeetEmmy !? MetEmmy:
        Go talk to the silver pawn.
    - QuestMeetEmmy !? OpenedJournal:
      Check out the new entries in your journal, then head back to Emmy.
    - QuestMeetEmmy !? ToldEmmyJournal:
        You read your journal--head back and tell Emmy.
    - QuestMeetEmmy ? ToldEmmyJournal:
        You read your journal and told Emmy.
}

-> DONE

= GetTime_quest

{
    - QuestGetTime ? ToldEmmyTime: Quest Complete.
    - QuestGetTime ? GotAnswer: Go tell Emmy.
    - QuestGetTime ? AskedTime: -> FindShapes_quest
    - QuestGetTime ? EmmyAsked: go talk to Blue.
    - QuestGetTime !? EmmyAsked: Go talk to Emmy.
    }

-> DONE

= FindShapes_quest

{
    - QuestFindShapes ? ToldBlue:
        You found all of Blue's shapes and told her where they were.
    - InventoryItems ? (cone, cube, sphere):
        ~ QuestFindShapes += GotShapes
        You've found all the shapes. {QuestFindShapes ? BlueAsked:Head back to blue|I wonder if anyone's looking for these}.
    - QuestFindShapes ? BlueAsked:
        ~ temp foundshapes = InventoryItems ^ shapes
        Blue asked you to find her shapes before she'll give you the time. <>
        {foundshapes: You've found the {list_with_commas(foundshapes)}.} You still need the {list_with_commas(not_in(shapes, InventoryItems))}. # Linetime: 2.5
    - else:
        You've found a {list_with_commas(InventoryItems ^ shapes)}.
}

-> DONE

=== Journal ===
LIST JournalEntries = journal, dialogue, quests, EmmyTime, BlueShapes
VAR JournalBookmark = -> empty_entry

<- JournalBookmark

+ {JournalEntries has journal} [The Journal]
    ~ JournalBookmark = -> journal_entry
    -> Journal
+ {JournalEntries has quests} [Quests]
    ~ JournalBookmark = -> quests_entry
    -> Journal
+ {JournalEntries has dialogue} [Dialogue]
    ~ JournalBookmark = -> dialogue_entry
    -> Journal
+ {JournalEntries has EmmyTime} [Quest: Give Emmy the time]
    ~ JournalBookmark = -> EmmyTime_entry
    -> Journal
+ {JournalEntries has BlueShapes} [Quest: Find Blue's Shapes]
    ~ JournalBookmark = -> BlueShapes_entry
    -> Journal
    
- -> DONE

= empty_entry
This is the player journal.

You don't have any entries yet--you'll get a notification in the top right when entries are added.

-> DONE

= journal_entry
~ QuestMeetEmmy += OpenedJournal

This is the player character's Journal.<br>

In the Ink file, Journal entries each have their own stitch in the "Journal" knot.<b>

Full instructions for adding journal entries can be found in README-AdventureDemo.md.

The quick version is that each entry is stored in a stitch within the Journal knot in the ink file. At the top of the knot, a sticky choice block handles the journal's table of contents, and lists all journal entries the player can currently see.

The current entry the player is looking at is stored in the JournalBookmark variable in Ink. This ensures that when the player opens the journal, they'll be returned to the last viewed entry.

The logic that controls showing/hiding the journal panel and updating the contents when the player chooses an entry from the list is found in WBP_Display_Adventure.

-> DONE

= quests_entry

Quests in this demo are making heavy use of LISTs as state machines to track the player's progress.

We're again using flow-switching to know when to display quest text. Text for each quest is stored in its own stitch in the Quests knot. Switching logic within the stitch will show the appropriate text depending on the player's progress.

At the moment, there's no Unreal-specific setup to do for quest text--it will be handled by the same Blueprint logic being used for dialogue.

That's because there's no dedicated UI surface for Quest Text in this demo. Since it's not possible for the game to be in two flows at the same time, we can't display quest text and dialogue simultaneously--so they share a UI panel.

Because quest text is ephemeral, the demo includes journal entries showing the current status of quests, so that the player can refer back to see what their current goals are.

In a full game, it may make sense to keep the quest log in its own panel--but for the demo, the concepts are the same whether they're in the Journal panel or their own widget.

-> DONE

= EmmyTime_entry

Emmy asked you to ask Blue what time it is.

{
    - QuestGetTime ? ToldEmmyTime: You had to find Blue's shapes first, but {InventoryItems ? watch:she gave you her watch, so you were able to tell Emmy the time|she still refused to give you the time of day, and you had to tell Emmy}.
    - QuestGetTime ? GotAnswer:
        You told Blue where to find her shapes, {InventoryItems ? watch:and she gave you her watch|but she didn't like your tone, so she refused to tell you the time}.
        You should go tell Emmy.
    - QuestGetTime ? AskedTime: Blue won't give you the time until you  {QuestFindShapes < GotShapes:find her shapes and }tell her where to find {QuestFindShapes < GotShapes:them|her shapes}.
    - else: You should go talk to Blue.
    }

-> DONE

= BlueShapes_entry

Blue asked you to find her shapes before she'll give you the time.

{
    - QuestFindShapes ? ToldBlue:
        You found all three and told her where they were.
        
        {InventoryItems ? watch: Blue gave you her watch in exchange}.
    - InventoryItems ? (cone, cube, sphere):
        ~ QuestFindShapes += GotShapes
        You've found all the shapes. You should head back and tell Blue.
    - QuestFindShapes ? BlueAsked:
        ~ temp foundshapes = InventoryItems ^ shapes
        {foundshapes: You've found the {list_with_commas(foundshapes)}.} You still need the {list_with_commas(not_in(shapes, InventoryItems))}.
}

-> DONE

= dialogue_entry
~ QuestMeetEmmy += OpenedJournal
    
The Dialogue pattern in this demo is using trigger volumes to initiate dialogue for each NPC, and each NPC has their own knot in the AdventureDemo.ink: NPC_Emmy and NPC_Blue.

The logic to update the UI with each line of dialogue and handle player choices lives in `WBP_Display_Adventure`.

Check README-AdventureDemo.ink for an explanation of Inkpot concepts including Flows and Reading Ink Tags and how they're used in this demo.

-> DONE