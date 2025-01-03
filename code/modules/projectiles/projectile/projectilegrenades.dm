/obj/item/projectile/bullet/grenade
	name = "grenade shell"
	icon_state = "grenade"
	damage_types = list(BRUTE = 5)
	agony = 10
	armor_penetration = 0
	embed = FALSE
	sharp = FALSE
	check_armour = ARMOR_BULLET
	step_delay = 1.2
	// recoil = 7 // Unlike shotgun shells, this one doesn't rely on velocity, but payload instead Occulus Edit: No recoil yet
	can_ricochet = FALSE

/obj/item/projectile/bullet/grenade/Move()	//Makes grenade shells cause their effect when they arrive at their target turf
	if(get_turf(src) == get_turf(original))
		if(QDELETED(src)) return // Occulus Edit: CRASH FIX
		
		grenade_effect(get_turf(src))
		qdel(src)
	else
		..()

/obj/item/projectile/bullet/grenade/on_hit(atom/target)	//Allows us to cause different effects for each grenade shell on hit
	if(QDELETED(src)) return // Occulus Edit: CRASH FIX
	
	grenade_effect(target)
	qdel(src) // Occulus Edit: CRASH FIX

/obj/item/projectile/bullet/grenade/proc/grenade_effect(target)
	return

/obj/item/projectile/bullet/grenade/blast
	name = "blast shell"
	var/devastation_range = 0
	var/heavy_impact_range = 0
	var/light_impact_range = 3
	var/flash_range = 10

/obj/item/projectile/bullet/grenade/blast/grenade_effect(target)
	explosion(target, devastation_range, heavy_impact_range, light_impact_range, flash_range)

/obj/item/projectile/bullet/grenade/frag
	name = "frag shell"
	var/range = 7
	var/f_type = /obj/item/projectile/bullet/pellet/fragment
	var/f_amount = 30
	var/f_damage = 12
	var/f_step = 8
	var/same_turf_hit_chance = 15

/obj/item/projectile/bullet/grenade/frag/weak
	name = "frag shell"
	f_damage = 8
	f_step = 4

/obj/item/projectile/bullet/grenade/frag/grenade_effect(target)
	fragment_explosion(target, range, f_type, f_amount, f_damage, f_step, same_turf_hit_chance)

/obj/item/projectile/bullet/grenade/emp
	var/heavy_emp_range = 3
	var/light_emp_range = 8

/obj/item/projectile/bullet/grenade/emp/grenade_effect(target)
	empulse(target, heavy_emp_range, light_emp_range)

/obj/item/projectile/bullet/grenade/frag/sting
	name = "sting shell"
	f_type = /obj/item/projectile/bullet/pellet/fragment/rubber/weak
	f_amount = 18
	f_damage = 5
	f_step = 8

/obj/item/projectile/bullet/grenade/frag/sting/grenade_effect(target)
	fragment_explosion(target, range, f_type, f_amount, f_damage, f_step, same_turf_hit_chance)