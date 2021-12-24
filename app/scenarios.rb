def define_scenarios(args)
	args.state.scenarios.list = {}
	args.state.scenarios.list[:tutorial] = {}
	args.state.scenarios.list[:tutorial][:title] = "Tutorial Scenario"
	args.state.scenarios.list[:tutorial][:description] = "A learning scenario intended to walk you through the core mechanics of the game, as well as demonstrate some of the capabilities of DPG's TeenyTinyCityBuilder engine"
	args.state.scenarios.list[:tutorial][:events] = []
	events = args.state.scenarios.list[:tutorial][:events]
	#events << new_event()
	
	events << new_event(:add_log, "Welcome to the tutorial", nil, 1)
	events << new_event(:add_log, "This tutorial intends to show you the basics of TeenyTinyCityBuilder", nil, 1)
	events << new_event(:add_log, "This area of the screen is called the Event Log. It contains important messages, including tutorial instructions and notifications for new or completed objectives.", nil, 2)
	events << new_event(:add_log, "You'll notice the most recent message is highlighted.", nil, 3)
	events << new_event(:add_log, "You can expand this event log by clicking the 'Toggle Menu' button above.", nil, 1)
	events << new_event(:add_log, "To the left along the bottom of the screen is the main selection box. Within it, you should see the Woodcutter's Hut.", nil, 2)
	events << new_event(:add_log, "Select the woodcutter from the list at the bottom of your screen. If you don't see a woodcutter, select 'Resource Gathering Buildings' from the list to the right.", nil, 2)
	
	# objective[:resource_amount] <= objective[:check_against][objective[:resource_type]]
	# trigger: ## {check_against: , resource_type: , resource_amount: }
	
	events << new_event(:add_log, "Once the woodcutter is selected, the main selection box will show you a description as well as the cost of the building. The cost is paid when the building is constructed. The consumption is consumed at the end of an ingame day, and any production is only produced if the consumption is satisfied.", nil, 3)
	events << new_event(:add_log, "Build the woodcutter using the Build button.", nil, 6)
	events << new_event(:add_log, "Excellent! The woodcutter has been constructed and you can now see the production ticking up in the lefthand window. This window also shows your current inventory. Note that the production shown here is the nominal production and does not reflect production impacted by unfulfilled consumption costs.", {check_against: args.state.built_structures, resource_type: :woodcutter, resource_amount: 1}, 0)
	events << new_event(:add_log, "Now that we have some wood coming in, food should be the next priority. Build a forager's hut.", nil, 10)
	events << new_event(:add_log, "As our city grows, food income will be more and more important. Mining in particular will consume food.", {check_against: args.state.built_structures, resource_type: :forager, resource_amount: 1}, 0)
	
	args.state.scenarios.list[:default] = {}
	args.state.scenarios.list[:default][:title] = "Default Scenario"
	args.state.scenarios.list[:default][:description] = "A null scenario to allow testing of other parts of the game"
	args.state.scenarios.list[:default][:events] = []
	events = args.state.scenarios.list[:default][:events]
	
	events << new_event(:add_log, "Don't know how you managed that, but that's the end of the scenario.", {check_against: args.state.built_structures, resource_type: :wonder, resource_amount: 1}, 0)
	
	events = args.state.scenarios.list[args.state.current_scenario][:events]
	args.state.scenario.current_event = events.shift
	args.state.scenario.running = true
	args.state.scenarios.ready = true
end