/**
 * A component that manages the ability to grow plants in whatever the hell it's on.
 */
/datum/component/hydroponics
	var/icon/overlay_status_source

	var/obj/item/seeds/plant //! The plant that is currently growing
	var/plant_status = HYDROPONICS_PLANT_STATUS_NO_PLANT //! The current status of the plant
	var/plant_health = 100 //! The health of the plant
	var/plant_age = 0 //! The age of the plant
	var/plant_toxicity = 0 //! The toxicity of the plant

	var/water_level = 0 //! The current water level
	var/water_level_max = 100 //! The maximum water level

	var/nutrient_usage = 1 //! The amount of nutrients used per tick
	var/nutrient_max = 100 //! The maximum amount of nutrients

	var/pest_stage = 0 //! The current stage of pests.
	var/weed_stage = 0 //! The current stage of weeds.

	var/modifier_yield = 1 //! The modifier for the plant's yield
	var/modifier_mutation = 1 //! The modifier for the plant's mutation chance

/datum/component/hydroponics/Initialize(
	icon/overlay_status_source,
)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	src.overlay_status_source = overlay_status_source

	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(parent_update_overlays))
	START_PROCESSING(SSobj, src)

/datum/component/hydroponics/proc/parent_update_overlays(datum/source, list/overlays)
	SIGNAL_HANDLER
	if(!isnull(plant))
		overlays += get_overlay_seed()
		overlays += get_overlay_status()

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

/datum/component/hydroponics/proc/get_overlay_status()
	if(isnull(overlay_status_source))
		return null
	var/atom/parent_atom = parent
	var/list/status_overlays = list()

	if(water_level <= 10)
		status_overlays += mutable_appearance(overlay_status_source, OVERLAY_ICONSTATE_LOW_WATER)
	if(parent_atom.reagents.total_volume <= 2)
		status_overlays += mutable_appearance(overlay_status_source, OVERLAY_ICONSTATE_LOW_NUTRIENTS)
	if(plant_health <= (plant.endurance / 2))
		status_overlays += mutable_appearance(overlay_status_source, OVERLAY_ICONSTATE_LOW_HEALTH)
	if(weed_stage >= 5 || pest_stage >= 5 || plant_toxicity >= 40)
		status_overlays += mutable_appearance(overlay_status_source, OVERLAY_ICONSTATE_BAD)
	if(plant_status == HYDROPONICS_PLANT_STATUS_HARVESTABLE)
		status_overlays += mutable_appearance(overlay_status_source, OVERLAY_ICONSTATE_HARVESTABLE)

	return status_overlays

/datum/component/hydroponics/proc/update_parent_name()
	SIGNAL_HANDLER
	var/atom/parent_atom = parent
	if(isnull(plant))
		parent_atom.name = parent_atom::name
	else
		parent_atom.name = "[parent_atom::name] ([plant.name])"

/datum/component/hydroponics/process(seconds_per_tick)
	return
