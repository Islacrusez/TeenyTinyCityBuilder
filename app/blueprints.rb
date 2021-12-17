	args.state.blueprints.structures[:name] =
		{	name:		"LongName",
			cost:		{material: amount},
			production:	{material: amount},
			consumption: {material: amount},
			available: false,
			unlocks: [:name]
			type: :gather,
			type: :process,
			type: :unit,
			type: :upgrade,
			description: "Description."
		}
		
	args.state.blueprints.structures[:woodcutter] =
		{	name:		"Woodcutter's Hut",
			cost:		{workers: 1},
			production:	{wood: 30},
			#consumption: {material: amount},
			available: true,
			unlocks: [:charcoal_pile, :quarry, :forager, :carpenter]
			type: :gather,
			#type: :process,
			#type: :unit,
			#type: :upgrade,
			description: "Description."
		}
		
	args.state.blueprints.structures[:charcoal_pile] =
		{	name:		"Charcoal Pile",
			cost:		{workers: 1},
			production:	{coal: 20},
			consumption: {wood: 200},
			available: false,
			#unlocks: [:name]
			#type: :gather,
			type: :process,
			#type: :unit,
			#type: :upgrade,
			description: "Description."
		}
		
	args.state.blueprints.structures[:quarry] =
		{	name:		"Stone Quarry",
			cost:		{wood: 50, workers: 5},
			production:	{stone: 10},
			consumption: {food: 5},
			available: false,
			unlocks: [:coal_mine, :iron_mine]
			type: :gather,
			#type: :process,
			#type: :unit,
			#type: :upgrade,
			description: "Description."
		}
		
	args.state.blueprints.structures[:coal_mine] =
		{	name:		"Coal Mine",
			cost:		{workers: 3, wood: 100},
			production:	{coal: 30},
			consumption: {wood: 3, food: 30},
			available: false,
			#unlocks: [:name]
			type: :gather,
			#type: :process,
			#type: :unit,
			#type: :upgrade,
			description: "Description."
		}
		
	args.state.blueprints.structures[:iron_mine] =
		{	name:		"Iron Mine",
			cost:		{workers: 3, wood: 100},
			production:	{iron_ore: 30},
			consumption: {wood: 3, food: 30},
			available: false,
			unlocks: [:smelter]
			type: :gather,
			#type: :process,
			#type: :unit,
			#type: :upgrade,
			description: "Description."
		}

	args.state.blueprints.structures[:smelter] =
		{	name:		"Smelter",
			cost:		{stone: 100, workers: 1},
			production:	{iron: 5},
			consumption: {coal: 15, iron_ore: 10},
			available: false,
			unlocks: [:blacksmith]
			#type: :gather,
			type: :process,
			#type: :unit,
			#type: :upgrade,
			description: "Description."
		}
		
	args.state.blueprints.structures[:blacksmith] =
		{	name:		"Blacksmith",
			cost:		{stone: 40, iron: 30, wood: 50, workers: 3},
			production:	{tools: 5},
			consumption: {iron: 5, coal: 5},
			available: false,
			#unlocks: [:name]
			#type: :gather,
			type: :process,
			#type: :unit,
			#type: :upgrade,
			description: "Description."
		}
		
	args.state.blueprints.structures[:carpenter] =
		{	name:		"Carpenter's Workshop",
			cost:		{wood: 100, iron: 10, workers: 1},
			production:	{planks: 10},
			consumption: {wood: 5},
			available: false,
			unlocks: [:boat_builder]
			#type: :gather,
			type: :process,
			#type: :unit,
			#type: :upgrade,
			description: "Description."
		}
	args.state.blueprints.structures[:boat_builder] =
		{	name:		"Boat Builder's Workshop",
			cost:		{wood: 200, stone: 200, workers: 2},
			#production:	{material: amount},
			#consumption: {material: amount},
			available: false,
			unlocks: [:boats, :fishing_wharf, :shipyard]
			#type: :gather,
			#type: :process,
			#type: :unit,
			type: :upgrade,
			description: "Description."
		}
		
	args.state.blueprints.structures[:boats] =
		{	name:		"Small boat",
			cost:		{wood: 50},
			#production:	{material: amount},
			consumption: {wood: 1},
			available: false,
			unlocks: [:name]
			#type: :gather,
			#type: :process,
			type: :unit,
			#type: :upgrade,
			description: "Description."
		}
		
	args.state.blueprints.structures[:fishing_wharf] =
		{	name:		"Fishing Wharf",
			cost:		{wood: 100, boats: 3, workers: 5},
			production:	{food: 100},
			consumption: {wood: 7},
			available: false,
			unlocks: [:dock]
			type: :gather,
			#type: :process,
			#type: :unit,
			#type: :upgrade,
			description: "Description."
		}
		
	args.state.blueprints.structures[:dock] =
		{	name:		"Dock",
			cost:		{stone: 500, wood: 200, workers: 10},
			#production:	{material: amount},
			#consumption: {material: amount},
			available: false,
			#unlocks: [:trading_ship]
			#type: :gather,
			#type: :process,
			#type: :unit,
			type: :upgrade,
			description: "Description."
		}
		
	args.state.blueprints.structures[:shipyard] =
		{	name:		"Shipyard",
			cost:		{wood: 1000, stone: 200, workers: 20},
			#production:	{material: amount},
			#consumption: {material: amount},
			available: false,
			unlocks: [:trading_ship]
			#type: :gather,
			#type: :process,
			#type: :unit,
			type: :upgrade,
			description: "Description."
		}
		
	args.state.blueprints.structures[:trading_ship] =
		{	name:		"Trading Ship",
			cost:		{wood: 1000, sails: 300, workers: 100, stone: 100},
			#production:	{material: amount},
			consumption: {food: 100},
			available: false,
			#unlocks: [:name]
			#type: :gather,
			#type: :process,
			type: :unit,
			#type: :upgrade,
			description: "Description."
		}
		
