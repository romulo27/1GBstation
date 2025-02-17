// There, now `stat` is a proper state-machine

/mob/living/proc/KnockOut(updating = TRUE)
	if(stat == DEAD)
		log_runtime(EXCEPTION("KnockOut called on a dead mob."), src)
		return 0
	else if(stat == UNCONSCIOUS)
		return 0
	create_attack_log("<font color='red'>Fallen unconscious at [atom_loc_line(get_turf(src))]</font>")
	add_attack_logs(src, null, "Fallen unconscious", ATKLOG_ALL)
	log_game("[key_name(src)] fell unconscious at [atom_loc_line(get_turf(src))]")
	set_stat(UNCONSCIOUS)
	ADD_TRAIT(src, TRAIT_FLOORED, STAT_TRAIT)
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, STAT_TRAIT)
	ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, STAT_TRAIT)
	if(updating)
		update_sight()
		update_blind_effects()
		set_typing_indicator(FALSE)
	return 1

/mob/living/proc/WakeUp(updating = TRUE)
	if(stat == DEAD)
		log_runtime(EXCEPTION("WakeUp called on a dead mob."), src)
		return 0
	else if(stat == CONSCIOUS)
		return 0
	create_attack_log("<font color='red'>Woken up at [atom_loc_line(get_turf(src))]</font>")
	add_attack_logs(src, null, "Woken up", ATKLOG_ALL)
	log_game("[key_name(src)] woke up at [atom_loc_line(get_turf(src))]")
	set_stat(CONSCIOUS)
	REMOVE_TRAITS_IN(src, STAT_TRAIT)
	if(updating)
		update_sight()
		update_blind_effects()
	return 1

// death() is used to make a mob die

// handles revival through other means than cloning or adminbus (defib, IPC repair)
/mob/living/proc/update_revive(updating = TRUE)
	if(stat != DEAD)
		return 0
	create_attack_log("<font color='red'>Came back to life at [atom_loc_line(get_turf(src))]</font>")
	add_attack_logs(src, null, "Came back to life", ATKLOG_ALL)
	log_game("[key_name(src)] came back to life at [atom_loc_line(get_turf(src))]")
	set_stat(UNCONSCIOUS) // this is done as `WakeUp` early returns if they are `stat = DEAD`
	WakeUp()
	GLOB.dead_mob_list -= src
	GLOB.alive_mob_list |= src
	if(mind)
		remove_from_respawnable_list()
	timeofdeath = null
	if(updating)
		update_blind_effects()
		update_sight()
		updatehealth("update revive")
		hud_used?.reload_fullscreen()

	SEND_SIGNAL(src, COMSIG_LIVING_REVIVE, updating)

	if(mind)
		for(var/S in mind.spell_list)
			var/obj/effect/proc_holder/spell/spell = S
			spell.updateButtonIcon()

	return 1

/mob/living/proc/check_death_method()
	return TRUE
