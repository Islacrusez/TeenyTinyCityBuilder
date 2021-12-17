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