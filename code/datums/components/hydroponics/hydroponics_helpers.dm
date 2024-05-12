/// Sets the plant status to the specified value and sends a signal to the parent atom if the status has changed.
/datum/component/hydroponics/proc/set_plant_status(status)
	if(plant_status == status)
		return
	plant_status = status
	SEND_SIGNAL(parent, COMSIG_HYDROPONICS_PLANT_STATUS_CHANGED, status)

/// Helper function to add the specified amount of reagent to the parent atom.
/datum/component/hydroponics/proc/add_reagent(reagent_type, amount)
	var/atom/parent_atom = parent
	parent_atom.reagents.add_reagent(reagent_type, amount)

/// Returns the amount of the specified reagent in the parent atom.
/datum/component/hydroponics/proc/get_reagent_amount(reagent_type)
	var/atom/parent_atom = parent
	return parent_atom.reagents.get_reagent_amount(reagent_type)

/// Uses (removes) the specified amount of reagent from the parent atom.
/// Returns the amount of reagent actually used.
/datum/component/hydroponics/proc/use_reagent(reagent_type, amount)
	var/atom/parent_atom = parent
	return parent_atom.reagents.remove_reagent(reagent_type, amount)

/// Returns the toxicity level of the hydroponics system.
/datum/component/hydroponics/proc/get_toxicity()
	return get_reagent_amount(/datum/reagent/toxin)

/// Returns the amount of water.
/datum/component/hydroponics/proc/get_water()
	return get_reagent_amount(/datum/reagent/water)

/// Adjusts the toxicity level of the hydroponics system by the specified amount.
/datum/component/hydroponics/proc/adjust_toxicity(amount)
	if(amount < 0)
		use_reagent(/datum/reagent/toxin, amount)
		return

	var/atom/parent_atom = parent
	var/available_space = parent_atom.reagents.maximum_volume - parent_atom.reagents.total_volume
	if(available_space < amount) // not enough space? remove water
		use_reagent(/datum/reagent/water, amount - available_space)
	add_reagent(/datum/reagent/toxin, amount)

/**
 * Sets the plant to the specified seed type.
 * If the seed type is null, the current plant is removed.
 * You can also pass a seed instance directly.
 * Sends signals to the plant and parent atom as needed
 */
/datum/component/hydroponics/proc/set_growing(obj/item/seeds/seed_type)
	var/new_plant
	if(isnull(seed_type))
		if(!isnull(plant))
			set_plant_status(HYDROPONICS_PLANT_STATUS_NO_PLANT)
			SEND_SIGNAL(plant, COMSIG_SEEDS_REMOVED, parent)
			SEND_SIGNAL(parent, COMSIG_HYDROPONICS_PLANT_REMOVED)
			QDEL_NULL(plant)
		return

	if(!ispath(seed_type, /obj/item/seeds))
		if(ispath(seed_type)) // wrong path
			CRASH("call to [__PROC__] with invalid seed type path [seed_type]")
		if(!istype(seed_type)) // wrong type
			CRASH("call to [__PROC__] with a datum which is not a seed type [seed_type]")
		new_plant = seed_type
	else
		new_plant = new seed_type

	if(!isnull(plant))
		qdel(plant)
	plant = new_plant
	plant.forceMove(parent)

	set_plant_status(HYDROPONICS_PLANT_STATUS_GROWING)
	SEND_SIGNAL(plant, COMSIG_SEEDS_PLANTED, parent)
	SEND_SIGNAL(parent, COMSIG_HYDROPONICS_PLANT_CHANGED, plant)
	var/atom/parent_atom = parent
	parent_atom.update_appearance()

/**
 * Handles updating the self-sustaining status of the hydroponics system.
 * Sends a signal to the parent atom if the status has changed.
 */
/datum/component/hydroponics/proc/set_self_sustaining(status)
	if(self_sustaining == status)
		return
	self_sustaining = status
	SEND_SIGNAL(parent, COMSIG_HYDROPONICS_SELF_SUSTAINING_CHANGED, status)

/**
 * Handles updating the pest level.
 */
/datum/component/hydroponics/proc/set_pest_level(level)
	if(pest_level == level)
		return
	pest_level = level
	SEND_SIGNAL(parent, COMSIG_HYDROPONICS_PEST_LEVEL_CHANGED, level)

/**
 * Handles updating the weed level.
 */
/datum/component/hydroponics/proc/set_weed_level(level)
	if(weed_level == level)
		return
	weed_level = level
	SEND_SIGNAL(parent, COMSIG_HYDROPONICS_WEED_LEVEL_CHANGED, level)
