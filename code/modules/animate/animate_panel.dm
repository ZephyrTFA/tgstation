GLOBAL_DATUM(animate_panel, /datum/animate_panel)

/datum/animate_panel
	var/static/list/datum/animate_flag/flags
	var/static/list/datum/animate_easing/easings
	var/static/list/datum/animate_easing_flag/easing_flags
	var/static/list/datum/animate_argument/arguments

	var/list/cached_targets
	var/list/datum/animate_chain/animate_chains_by_user

/datum/animate_panel/New()
	..()

	if(isnull(flags))
		flags = list()
		for(var/datum/animate_flag/flag as anything in subtypesof(/datum/animate_flag))
			flags[flag::name] = new flag
		easings = list()
		for(var/datum/animate_easing/easing as anything in subtypesof(/datum/animate_easing))
			easings[easing::name] = new easing
		easing_flags = list()
		for(var/datum/animate_easing_flag/easing_flag as anything in subtypesof(/datum/animate_easing_flag))
			easing_flags[easing_flag::name] = new easing_flag
		arguments = list()
		for(var/datum/animate_argument/argument as anything in subtypesof(/datum/animate_argument))
			arguments[argument::name] = new argument

	cached_targets = list()
	animate_chains_by_user = list()

/datum/animate_panel/proc/get_chain_by_index(mob/user, index)
	if(!isnum(index))
		return null

	var/datum/animate_chain/chain = animate_chains_by_user[ref(user)]
	if(!chain)
		return null

	while(!isnull(chain) && chain.chain_index != index)
		chain = chain.next
	if(chain.chain_index == index)
		return chain

	return null

/datum/animate_panel/ui_static_data(mob/user)
	. = list()

	var/list/animate_flags = list()
	for(var/datum/animate_flag/flag as anything in flags)
		animate_flags[flag.name] = list(
			"description" = flag.description,
			"value" = flag.value,
		)
	.["animate_flags"] = animate_flags

	var/list/animate_easings = list()
	for(var/datum/animate_easing/easing as anything in easings)
		animate_easings[easing.name] = list(
			"description" = easing.description,
			"value" = easing.value,
		)
	.["animate_easings"] = animate_easings

	var/list/animate_easing_flags = list()
	for(var/datum/animate_easing_flag/easing_flag as anything in easing_flags)
		animate_easing_flags[easing_flag.name] = list(
			"description" = easing_flag.description,
			"value" = easing_flag.value,
		)
	.["animate_easing_flags"] = animate_easing_flags

	var/list/animate_arguments = list()
	for(var/datum/animate_argument/argument as anything in arguments)
		animate_arguments[argument.name] = list(
			"description" = argument.description,
			"allowed_types" = list(),
		)
		for(var/arg in argument.arg_types)
			animate_arguments[argument.name]["allowed_types"] += list("[arg]")
	.["animate_arguments"] = animate_arguments

	return .

/datum/animate_panel/ui_data(mob/user)
	. = list()
	.["target"] = cached_targets[ref(user)]

	.["chain"] = list()
	var/datum/animate_chain/chain = animate_chains_by_user[ref(user)]
	while(!isnull(chain))
		.["chain"] += list(chain.serialize_list(list(), list()))
		chain = chain.next

	return .

/datum/animate_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	var/mob/user = ui.user
	switch(action)
		if("export_json")
		if("export_dm")
#warn todo

		if("wipe")
			animate_chains_by_user -= ref(user)
			return TRUE

		if("apply")
			var/target_text = cached_targets[ref(user)]
			var/target = (findtext(target_text, "ckey_") == 1) ? GLOB.directory[copytext(target_text, 6)] : locate(target_text)
			if(!target)
				return

			chain?.apply(target)
			return TRUE

		if("revert")
			var/target = locate(cached_targets[ref(user)])
			if(!target)
				return
			animate(target, flags = ANIMATION_END_NOW)
			return TRUE

		if("insert_chain")
			var/after = params["insert_after"]
			if(!isnum(after))
				return

			if(after == 0 || !chain)
				var/datum/animate_chain/front = new
				front.next = chain
				animate_chains_by_user[ref(user)] = front
				return TRUE

			var/datum/animate_chain/iteration = chain.next
			var/datum/animate_chain/inserted = new
			inserted.chain_index = after + 1

			while(!isnull(iteration) && iteration.chain_index < after)
				iteration = iteration.next
			if(iteration.chain_index != after)
				return

			inserted.next = iteration.next
			iteration.next = inserted
			iteration = inserted.next
			while(!isnull(iteration))
				iteration.chain_index += 1
				iteration = iteration.next

			return TRUE

		if("drop_chain")
			var/index = params["drop_index"]
			if(!isnum(index) || !chain)
				return

			if(index == 1)
				animate_chains_by_user[ref(user)] = chain.next
				chain.next = null
				return TRUE

			var/datum/animate_chain/before_dropped = get_chain_by_index(user, index - 1)
			var/datum/animate_chain/dropped = before_dropped.next
			before_dropped.next = dropped.next
			dropped.next = null

			return TRUE

		if("drop_argument")
			var/datum/animate_chain/chain = get_chain_by_index(user, params["drop_param_index"])
			if(isnull(chain))
				return

			var/param_name = params["drop_param_name"]
			if(!istext(param_name) || !(param_name in arguments))
				return
			chain.vars[param_name] = null

			return TRUE

		if("set_argument")
			var/datum/animate_chain/chain = get_chain_by_index(user, params["set_param_index"])
			if(isnull(chain))
				return

			var/param_name = params["set_param_name"]
			if(!istext(param_name) || !(param_name in arguments))
				return

			var/datum/animate_argument/argument_definition = arguments[param_name]
			var/list/valid_types = list()
			for(var/valid_type in argument_definition.arg_types)
				valid_types["[valid_type]"] = TRUE

			var/param_type = params["set_param_type"]
			if(!(param_type in valid_types))
				return
			if(!argument_definition.handle_set(user, chain, param_type, params["set_param_value"]))
				to_chat(user, span_warning("Failed to set argument!"))
				return

			return TRUE

#warn todo
