/obj/machinery/appliance/cooker
	//name = "Plancha"		//This is technically not a machine, I am an idiot
	//desc = "A flat-topped grill for cooking things like hamburgers or steaks on."
	icon_state = "null"
	cooking_power = 0
	var/optimal_power = 1.1//cooking power at 100%

	var/light_x = 0
	var/light_y = 0
	cooking_coeff = 0
	cooking_power = 0
	flags = null
	var/starts_with = list()


/obj/machinery/appliance/cooker/MouseEntered(location, control, params)
	. = ..()
	var/list/modifiers = params2list(params)
	if(modifiers["shift"] && get_dist(usr, src) <= 2)
		params = replacetext(params, "shift=1;", "") // tooltip doesn't appear unless this is stripped
		var/description = ""
		if(isemptylist(cooking_objs))
			description = "It is empty."
		else
			description = "Contains...<ul>"
			for(var/datum/cooking_item/CI in cooking_objs)
				description += "<li>\a [CI.container.label(null, CI.combine_target)], [report_progress(CI)]</li>"
			description += "</ul>"
		if(!stat)
			if(temperature < min_temp)
				description += "[src] is still heating up and is too cold to cook anything yet."
			else
				description += "It is running at [round(get_efficiency(), 0.1)]% efficiency!"
			description += "<br>Temperature: [round(temperature - T0C, 0.1)]C / [round(optimal_temp - T0C, 0.1)]C"
		else
			description += "It is switched off."
		openToolTip(usr, src, params, name, description)

/obj/machinery/appliance/cooker/MouseExited(location, control, params)
	. = ..()
	closeToolTip(usr)

/obj/machinery/appliance/cooker/list_contents(var/mob/user)
	if (length(cooking_objs))
		var/string = "Contains...</br>"
		var/num = 0
		for (var/a in cooking_objs)
			var/datum/cooking_item/CI = a
			num++
			if (CI && CI.container)
				string += "- [CI.container.label(num)], [report_progress(CI)]</br>"
		to_chat(usr, string)
	else
		to_chat(usr, SPAN_NOTICE("It's empty."))

/obj/machinery/appliance/cooker/proc/get_efficiency()
	. = (cooking_power / optimal_power) * 100

/obj/machinery/appliance/cooker/Initialize()
	. = ..()
	cooking_objs = list()
	for(var/cctype in starts_with)
		if (length(cooking_objs) >= max_contents)
			break
		var/obj/item/reagent_containers/cooking_container/CC = new cctype(src)
		var/datum/cooking_item/CI = new /datum/cooking_item/(CC)
		cooking_objs.Add(CI)
	cooking = 0

	queue_icon_update()

/obj/machinery/appliance/cooker/attempt_toggle_power(mob/user)
	. = ..()
	switch(use_power)
		if(on)
			hot = TRUE
		if(off)
			hot = FALSE	//I wish I could call this cold, but I can't
	update_icon()

/obj/machinery/appliance/cooker/update_icon()
	overlays.Cut()
	var/image/light
	if (use_power == 2 && !stat)
		light = image(icon, "light_on")
	else
		light = image(icon, "light_off")
	light.pixel_x = light_x
	light.pixel_y = light_y
	overlays += light

/obj/machinery/appliance/cooker/machinery_process()
	if(!stat)
		update_cooking_power() // update!
	for(var/cooking_obj in cooking_objs)
		var/datum/cooking_item/CI = cooking_obj
		if((CI.container.flags && NOREACT) || isemptylist(CI.container?.reagents.reagent_volumes))
			continue
		CI.container.reagents.set_temperature(min(temperature, CI.container.reagents.get_temperature() + 10*SIGN(temperature - CI.container.reagents.get_temperature()))) // max of 5C per second
	return ..()

/obj/machinery/appliance/cooker/power_change()
	. = ..()
	queue_icon_update()

/*
/obj/machinery/appliance/cooker/update_cooking_power()
	if(hot)
		cooking_power = optimal_power
	if(!hot)
		cooking_power = 0
*/

//Cookers do differently, they use containers
/obj/machinery/appliance/cooker/has_space(var/obj/item/I)
	if (istype(I, /obj/item/reagent_containers/cooking_container))
		//Containers can go into an empty slot
		if (length(cooking_objs) < max_contents)
			return TRUE
	else
		//Any food items directly added need an empty container. A slot without a container cant hold food
		for (var/datum/cooking_item/CI in cooking_objs)
			if (CI.container.check_contents() == CONTAINER_EMPTY)
				return CI

	return FALSE

/obj/machinery/appliance/cooker/add_content(var/obj/item/I, var/mob/user)
	var/datum/cooking_item/CI = ..()
	if (CI && CI.combine_target)
		to_chat(user, "[I] will be used to make a [selected_option]. Output selection is returned to default for future items.")
		selected_option = null
