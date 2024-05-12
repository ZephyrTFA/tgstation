/**
 * A component that manages the ability to grow plants in whatever the hell it's on.
 */
/datum/component/hydroponics
	var/icon/overlays_source

	var/obj/item/seeds/plant //! The plant that is currently growing
	var/plant_status = HYDROPONICS_PLANT_STATUS_NO_PLANT //! The current status of the plant
	var/plant_health = 100 //! The health of the plant
	var/plant_age = 0 //! The age of the plant

	var/base_water_usage = 3 //! The base amount of water used per tick
	var/water_usage = 3 //! The effective amount of water used per tick

	var/base_nutrient_usage = 3 //! The base amount of nutrients used per tick
	var/nutrient_usage = 3 //! The effective amount of nutrients used per tick

	var/pest_level = 0 //! The current level of pests.
	var/weed_level = 0 //! The current level of weeds.

	var/modifier_yield = 1 //! The modifier for the plant's yield
	var/modifier_mutation = 1 //! The modifier for the plant's mutation chance

	var/self_sustaining = FALSE //! Whether the hydroponics system is self-sustaining (automatic watering/nutrients)
	var/we_added_screentips = FALSE //! Whether we've added the contextual screentips for the parent atom

/datum/component/hydroponics/Initialize(
	icon/overlays_source = null,
)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	src.overlays_source = overlays_source
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(parent_update_overlays))
	RegisterSignal(parent, COMSIG_MACHINERY_REFRESH_PARTS, PROC_REF(parent_parts_updated))
	START_PROCESSING(SSobj, src)

	var/static/list/hovering_item_typechecks = list(
		/obj/item/plant_analyzer = list(
			SCREENTIP_CONTEXT_LMB = "Scan Stats",
			SCREENTIP_CONTEXT_RMB = "Scan Chemicals"
		),
		/obj/item/cultivator = list(
			SCREENTIP_CONTEXT_LMB = "Remove Weeds",
		),
		/obj/item/shovel = list(
			SCREENTIP_CONTEXT_LMB = "Empty",
		),
	)
	AddElement(/datum/element/contextual_screentip_item_typechecks, hovering_item_typechecks)
	var/atom/parent_atom = parent
	if(!(parent_atom.flags_1 & HAS_CONTEXTUAL_SCREENTIPS_1))
		parent_atom.register_context()
		we_added_screentips = TRUE

/datum/component/hydroponics/Destroy(force)
	if(we_added_screentips)
		var/atom/parent_atom = parent
		parent_atom.flags_1 &= ~HAS_CONTEXTUAL_SCREENTIPS_1
		parent_atom.UnregisterSignal(parent_atom, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM)
	if(!isnull(plant))
		QDEL_NULL(plant)
	return ..()

/datum/component/hydroponics/process(seconds_per_tick)
	return
