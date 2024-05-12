/// Handles attaching overlays to the parent atom.
/datum/component/hydroponics/proc/parent_update_overlays(datum/source, list/overlays)
	SIGNAL_HANDLER
	if(!isnull(plant))
		overlays += get_overlay_seed()
		overlays += get_overlay_status()

/// Returns a list of seed overlays to be displayed on the parent.
/// Currently only returns the plant's growing icon.
/datum/component/hydroponics/proc/get_overlay_seed()
	if(isnull(plant))
		return list()

	var/atom/parent_atom = parent
	var/mutable_appearance/plant_overlay = mutable_appearance(plant.growing_icon, layer = parent_atom.layer + 0.01)
	switch(plant_status)
		if(HYDROPONICS_PLANT_STATUS_DEAD)
			plant_overlay.icon_state = plant.icon_dead

		if(HYDROPONICS_PLANT_STATUS_HARVESTABLE)
			if(!plant.icon_harvest)
				plant_overlay.icon_state = "[plant.icon_grow][plant.growthstages]"
			else
				plant_overlay.icon_state = plant.icon_harvest

		else
			var/t_growthstate = clamp(round((plant_age / plant.maturation) * plant.growthstages), 1, plant.growthstages)
			plant_overlay.icon_state = "[plant.icon_grow][t_growthstate]"

	plant_overlay.pixel_y = plant.plant_icon_offset
	return list(plant_overlay)

/// Returns a list of status overlays to be displayed on the parent.
/datum/component/hydroponics/proc/get_overlay_status()
	if(isnull(overlays_source))
		return null
	var/atom/parent_atom = parent
	var/list/status_overlays = list()

	if(get_water() <= 10)
		status_overlays += mutable_appearance(overlays_source, OVERLAY_ICONSTATE_LOW_WATER)
	if(parent_atom.reagents.total_volume <= 2)
		status_overlays += mutable_appearance(overlays_source, OVERLAY_ICONSTATE_LOW_NUTRIENTS)
	if(plant_health <= (plant.endurance / 2))
		status_overlays += mutable_appearance(overlays_source, OVERLAY_ICONSTATE_LOW_HEALTH)
	if(weed_level >= 5 || pest_level >= 5 || get_toxicity() >= 40)
		status_overlays += mutable_appearance(overlays_source, OVERLAY_ICONSTATE_BAD)
	if(plant_status == HYDROPONICS_PLANT_STATUS_HARVESTABLE)
		status_overlays += mutable_appearance(overlays_source, OVERLAY_ICONSTATE_HARVESTABLE)
	if(self_sustaining)
		status_overlays += mutable_appearance(overlays_source, OVERLAY_ICONSTATE_SELF_SUSTAINING)

	return status_overlays

/// Updates the parent's name to include the plant's name.
/datum/component/hydroponics/proc/update_parent_name()
	SIGNAL_HANDLER
	var/atom/parent_atom = parent
	if(isnull(plant))
		parent_atom.name = parent_atom::name
	else
		parent_atom.name = "[parent_atom::name] ([plant.name])"

/// Reacts to the parent machine having its parts upgraded.
/datum/component/hydroponics/proc/parent_parts_updated(datum/source)
	SIGNAL_HANDLER
	var/obj/machinery/parent_machine = parent // this is safe because parts can only be added to machinery
	var/bin_count = 0
	var/bin_rating = 0
	var/servo_count = 0
	var/servo_rating = 0

	for(var/datum/stock_part/matter_bin/matter_bin in parent_machine.component_parts)
		bin_count += 1
		bin_rating += matter_bin.tier
	for(var/datum/stock_part/servo/servo in parent_machine.component_parts)
		servo_count += 1
		servo_rating += servo.tier

	if(bin_count == 0)
		bin_count = 1
		bin_rating = 1
	if(servo_count == 0)
		servo_count = 1
		servo_rating = 1

	var/bin_max_rating = bin_count * 4
	var/bin_upgrade_ratio = bin_rating / bin_max_rating
	var/bin_upgrade_effect = bin_upgrade_ratio * 3
	water_usage = base_water_usage / bin_upgrade_effect

	var/servo_max_rating = servo_count * 4
	var/servo_upgrade_ratio = servo_rating / servo_max_rating
	var/servo_upgrade_effect = servo_upgrade_ratio * 3
	nutrient_usage = base_nutrient_usage / servo_upgrade_effect
