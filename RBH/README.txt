Realm Bounty Hunter

Realm Bounty Hunter is a world PvP addon that allows players to place gold bounties on other player characters.  Bounty lists are shared with other RBH users on the realm via a public channel, a private channel with optional password, or a guild channel.  When a player kills another player character from the bounty list, the head of the killed character will be placed in a custom Kill Bag created by the addon.  Bounties can be claimed by meeting up with the issuer of the bounty and trading the head for gold.  

FAQ

Q: Can I place bounties on characters from other realms?
A: Yes.

Q: Can bounty lists be shared with players from other realms?
A: Not unless the realms are merged. 

Q: How can I be sure that a player selling me a head really killed that character?
A: Until Blizzard allows you to loot a character's head and trade it you can never be 100% certain a player is not faking the head.  However the goal of this addon is to make that as difficult as possible.  Without going into details, suffice to say that the heads created by this addon should provide about as much confidence in the kill as a screenshot.  

Also even though you can place bounties by manually entering the name and realm of the character, it is recommended that you do not use this method.  Instead click Add Bounty while targeting the character you want to place the bounty on.  This automatically populates the Name and Realm fields and will greatly enhance the certainty of the kill verification.

More features will be added in the future to aid in kill verification, including capturing combat logs which will be viewable from the head during the trade.

  
	v 1.0
		1. Place gold bounties on enemy players by adding to a bounty list
		2. Bounty lists are synched with others running the addon on the realm via a public realm channel
		3. Optionally use a private channel with password protection
		4. Player kills will place a head of the killed character in a custom bag
		5. Heads can be traded with other players to claim bounties
		6. When the transaction is complete, the bounty list will be marked as such
		7. RBH UI Panels: Bounty List, Kill Bag, Gather Intel, Options
	v 2.0
		1. Add verification of kills 
			a. Verification of target GUIDs.
				i. The GUID will not be shared on the network.  
				ii. The GUID will be recorded locally when placing a bounty on the current target
				iii. The GUID will be recorded locally when a kill is made
				iv. They two GUIDs will be compared during the trade to validate 
	v 3.0
		1. Mail heads COD to claim bounties
	

API Notes:

http://wowprogramming.com/docs/api/GetChannelRosterInfo

Azmadi#1240

Tasks:
1. Create function SendNetworkMessage(MODE, PREFIX, MSG, CHANNEL).  This will call sendAddonMessage() to all registered channels handling the seperation of bounties by channel.

2. Change bounty list table to remove all intel info (e.g. zone, level, race, etc.).  Structure will be a master table with subtables for each channel.

3. Add init functions to generate a list of members by channel determined by who is registered with a channel.  Guild channel is an exception to this as it will be handled by simply calling SendAddonMessage(PREFIX, MSG, GUILD).

