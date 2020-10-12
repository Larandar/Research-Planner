# Research Planner

Allow you to stop the micro-managing of science, because that so 2019.

This mod intent to enhance your research queue experience.

## Implemented features:

- **NONE**

## WIP features

- Runtime setting for trying the future planning strategy
  - First-found: get the first research found that is researchable
  - Cheapest: plan the research with cheapest combined crafting time
- Hacky CLI to manipulate planning, example:
```
/research-planner clear
/research-planner add sorting.by-cheapness
/research-planner add filter.ban-research-types types=artillery-shell-speed,follower-robot-count
/research-planner add filter.ban-research-packs packs=military
/research-planner show
```

## Planned features:

- Target a research and bee-line to it
- Auto-add least expensive research
- Production adaptive research?
- Infinite research prioritization
- Import/Export of settings

## Miscellaneous features

- Setting for changing research queue setting of a map
  - Include a setting for following map setting, which will emulate vanilla
    behavior if research queue setting is `after-victory`
- Notifications for finished researches
  - Setting for which forces will see which finished researches
  - Include a `taunt` option that tell your enemies you finished a research and
    only the type of packs used 😈

## Compatibility:

In theory, any research added should be compatible, including added science
pack. But added packs may require tweaking the weight in implemented strategies,
if you have recommendations please open an issue on github.

## Mod inspirations:

- [Deadlock's Research Notification](https://mods.factorio.com/mod/DeadlockResearchNotifications)
- [Auto Infinite Research](https://mods.factorio.com/mod/auto-infinite-research)
- [Auto Research](https://mods.factorio.com/mod/auto-research)
- [Rate Calculator](https://mods.factorio.com/mod/RateCalculator) and in general
  [all Raiguard GUI mods](https://mods.factorio.com/user/Raiguard)
